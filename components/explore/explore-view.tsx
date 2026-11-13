'use client'

import Link from 'next/link'
import { useMemo, useState } from 'react'
import { resolveUri, useIgnioTokens, type IgnioToken } from '@/lib/ignio-tokens'
import { useEthUsd } from '@/lib/token-data'

const PAGE = 12
const WAVE = [14, 28, 40, 26, 48, 22, 40, 16, 34, 12, 22, 10]
const FILTERS = ['All', 'Newest', 'Top market cap', 'Near graduation'] as const
type Filter = (typeof FILTERS)[number]

const short = (a: string) => `${a.slice(0, 6)}…${a.slice(-4)}`

function ago(ts: number) {
  if (!ts) return ''
  const s = Math.max(0, Math.floor(Date.now() / 1000 - ts))
  if (s < 3600) return `${Math.max(1, Math.floor(s / 60))}m ago`
  if (s < 86400) return `${Math.floor(s / 3600)}h ago`
  return `${Math.floor(s / 86400)}d ago`
}

function money(eth: number | null, usd: number | null) {
  if (eth === null) return '—'
  if (usd) {
    const v = eth * usd
    return v >= 1e6 ? `$${(v / 1e6).toFixed(2)}M` : v >= 1e3 ? `$${(v / 1e3).toFixed(1)}K` : `$${v.toFixed(0)}`
  }
  return `${eth >= 1 ? eth.toFixed(2) : eth.toPrecision(2)} ETH`
}

function Tile({ t, i }: { t: IgnioToken; i: number }) {
  const [broken, setBroken] = useState(false)
  return (
    <div className={`x-tile t${i % 6}`}>
      <b>{(t.symbol || t.name || '?').slice(0, 1).toUpperCase()}</b>
      {t.logo && !broken && (
        // eslint-disable-next-line @next/next/no-img-element
        <img src={resolveUri(t.logo)} alt={`${t.symbol} logo`} onError={() => setBroken(true)} loading="lazy" />
      )}
    </div>
  )
}

function TokenCard({ t, i, usd }: { t: IgnioToken; i: number; usd: number | null }) {
  return (
    <a className="x-tk" href={`https://robinhoodchain.blockscout.com/token/${t.token}`} target="_blank" rel="noreferrer">
      <Tile t={t} i={i} />
      <div className="meta">
        <div className="row"><h3>{t.name}</h3><span className="sym">{t.symbol}</span></div>
        <div className="nums">
          <div><small>Market cap</small><strong>{money(t.marketCapEth, usd)}</strong></div>
          <div style={{ textAlign: 'right' }}><small>Curve</small><strong>{t.graduated ? 'Graduated' : t.progress === null ? '—' : `${t.progress.toFixed(0)}%`}</strong></div>
        </div>
        <div className="x-bar"><span style={{ width: `${t.graduated ? 100 : t.progress ?? 0}%` }} /></div>
        <div className="by"><span>{ago(t.ts)}</span><span>by {short(t.creator)}</span></div>
      </div>
    </a>
  )
}

export default function ExploreView() {
  const [target, setTarget] = useState(PAGE)
  const { tokens, status } = useIgnioTokens(target)
  const usd = useEthUsd()
  const [q, setQ] = useState('')
  const [filter, setFilter] = useState<Filter>('All')

  const list = useMemo(() => {
    const s = q.trim().toLowerCase()
    let out = tokens.filter((t) => !s || t.name.toLowerCase().includes(s) || t.symbol.toLowerCase().includes(s) || t.token.toLowerCase().includes(s))
    if (filter === 'Top market cap') out = [...out].sort((a, b) => (b.marketCapEth ?? -1) - (a.marketCapEth ?? -1))
    if (filter === 'Near graduation') out = [...out].filter((t) => !t.graduated).sort((a, b) => (b.progress ?? -1) - (a.progress ?? -1))
    if (filter === 'Newest' || filter === 'All') out = [...out].sort((a, b) => (a.block < b.block ? 1 : -1))
    return out
  }, [tokens, q, filter])

  const top = useMemo(() => tokens.filter((t) => t.marketCapEth !== null).sort((a, b) => (b.marketCapEth ?? 0) - (a.marketCapEth ?? 0))[0], [tokens])
  const loading = status === 'loading'

  return (
    <>
      <div className="x-ex-head">
        <h1 className="x-h1">Explore<br />tokens.</h1>
        <p>Every token launched with Ignio, in one place. Search, filter and jump into any launch.</p>
      </div>

      <div className="x-search">
        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="M20 20l-4-4" /></svg>
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search by name, ticker or address" aria-label="Search tokens" />
        <span className="count">{tokens.length} {tokens.length === 1 ? 'token' : 'tokens'}</span>
      </div>

      <div className="x-chips">
        {FILTERS.map((f) => (
          <button key={f} type="button" className={`x-chip${filter === f ? ' on' : ''}`} onClick={() => setFilter(f)}>{f}</button>
        ))}
      </div>

      <div className={`x-feat${top ? '' : ' x-feat-solo'}`}>
        {top && (
          <a className="x-feat-top" href={`https://robinhoodchain.blockscout.com/token/${top.token}`} target="_blank" rel="noreferrer">
            <Tile t={top} i={0} />
            <div>
              <span className="x-tag" style={{ background: 'rgba(9,9,9,.12)' }}>Top market cap</span>
              <h2>{top.name}<br />{top.symbol}</h2>
              {top.description && <p>{top.description.length > 90 ? top.description.slice(0, 90) + '…' : top.description}</p>}
              <div className="stats">
                <div><small>Market cap</small><strong>{money(top.marketCapEth, usd)}</strong></div>
                <div><small>Curve</small><strong>{top.graduated ? 'Graduated' : top.progress === null ? '—' : `${top.progress.toFixed(0)}%`}</strong></div>
              </div>
            </div>
          </a>
        )}
        <div className="x-feat-cta">
          <div className="x-wave" aria-hidden="true">
            {WAVE.map((h, n) => <i key={n} style={{ height: h, animationDelay: `${n * 70}ms` }} />)}
          </div>
          <h2>Say it.<br />Launch it.</h2>
          <Link href="/launch" className="x-btn">Launch a token</Link>
        </div>
      </div>

      {list.length > 0 && (
        <div className="x-grid">
          {list.map((t, i) => <TokenCard key={t.token} t={t} i={i} usd={usd} />)}
        </div>
      )}

      {loading && (
        <div className="x-grid" aria-label="Loading tokens">
          {Array.from({ length: list.length ? 4 : 8 }, (_, i) => (
            <div key={i} className="x-tk x-skel"><div className="x-tile"><b>&nbsp;</b></div><div className="line" /><div className="line" style={{ width: '60%' }} /></div>
          ))}
        </div>
      )}

      {!loading && list.length === 0 && (
        <div className="x-empty">
          <h3>{status === 'error' ? 'Could not load tokens' : tokens.length ? 'No matches' : 'No Ignio tokens found yet'}</h3>
          <p>{status === 'error' ? 'The Robinhood Chain RPC did not respond. Try again in a moment.' : tokens.length ? 'Try a different search or filter.' : 'Be the first to launch one.'}</p>
          {status === 'error'
            ? <button type="button" className="x-btn dark" onClick={() => setTarget((n) => n + 1)}>Try again</button>
            : <Link href="/launch" className="x-btn dark">Launch a token</Link>}
        </div>
      )}

      {status === 'ready' && (
        <div className="x-more">
          <button type="button" className="x-btn dark" onClick={() => setTarget((n) => n + PAGE)}>
            {tokens.length >= target ? 'Load more' : 'Keep searching older blocks'}
          </button>
        </div>
      )}
    </>
  )
}
