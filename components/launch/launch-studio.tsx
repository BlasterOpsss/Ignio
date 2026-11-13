'use client'

import { useEffect, useRef, useState } from 'react'
import { useAccount, useReadContract } from 'wagmi'
import { formatEther, parseAbi } from 'viem'
import { LaunchForm } from '@/components/launch-page/launch-form'
import { TokenPreview } from '@/components/launch-page/token-preview'
import { isImpersonation } from '@/lib/brand-guard'
import { PONS_V2_FACTORY_ADDRESS } from '@/lib/hooks/use-launch-token'
import { EMPTY_DRAFT, GREETING, understand, type Draft, type Msg } from '@/lib/voice-chat'
import { useVoice } from '@/lib/use-voice'
import { robinhoodChain } from '@/lib/wagmi-config'

type Mode = 'voice' | 'normal'
type Snap = { image: string; name: string; symbol: string; description: string; xLink: string; telegram: string; website: string; fee: string }

const WAVE = [14, 28, 40, 26, 48, 22, 40, 16, 34, 12, 22, 10]
const FEE_ABI = parseAbi(['function launchFee() view returns (uint256)'])
const emptySnap = (d: Draft): Snap => ({ image: '', name: d.tokenName, symbol: d.tokenSymbol, description: d.description, xLink: d.xLink, telegram: d.telegram, website: d.website, fee: d.creatorTaxPct })

const MicIcon = () => (
  <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="9" y="3" width="6" height="11" rx="3" /><path d="M5 11a7 7 0 0 0 14 0M12 18v3" /></svg>
)
const DocIcon = () => (
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h8l5 5v13H6z" /><path d="M14 3v5h5M9 13h7M9 17h7" /></svg>
)
const CheckIcon = () => (
  <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="12" /><path d="M7 12.5l3.2 3.2L17 9" /></svg>
)

export default function LaunchStudio() {
  const { isConnected } = useAccount()
  const [mounted, setMounted] = useState(false)
  const [mode, setModeState] = useState<Mode>('normal')
  const [ready, setReady] = useState(false)
  const [draft, setDraft] = useState<Draft>(EMPTY_DRAFT)
  const [formKey, setFormKey] = useState(0)
  const [snap, setSnap] = useState<Snap>(emptySnap(EMPTY_DRAFT))
  const [msgs, setMsgs] = useState<Msg[]>([{ role: 'ai', text: GREETING }])
  const [input, setInput] = useState('')
  const [interim, setInterim] = useState('')
  const latest = useRef<Draft>(EMPTY_DRAFT) // what the form currently holds, so voice edits build on it
  const msgsRef = useRef<HTMLDivElement>(null)

  const { data: fee } = useReadContract({ address: PONS_V2_FACTORY_ADDRESS, abi: FEE_ABI, functionName: 'launchFee', chainId: robinhoodChain.id })

  // Read mode and any values handed over from the home page (/launch?name=…&symbol=…&description=…)
  useEffect(() => {
    setMounted(true)
    const q = new URLSearchParams(window.location.search)
    const d: Draft = {
      ...EMPTY_DRAFT,
      tokenName: (q.get('name') || '').slice(0, 32),
      tokenSymbol: (q.get('symbol') || '').toUpperCase().slice(0, 10),
      description: (q.get('description') || '').slice(0, 500),
    }
    latest.current = d
    setDraft(d)
    setSnap(emptySnap(d))
    if (q.get('mode') === 'voice') setModeState('voice')
    setReady(true)
  }, [])

  useEffect(() => {
    msgsRef.current?.scrollTo({ top: msgsRef.current.scrollHeight })
  }, [msgs, interim])

  function setMode(m: Mode) {
    setModeState(m)
    window.history.replaceState(null, '', m === 'voice' ? '/launch?mode=voice' : '/launch')
  }

  function send(text: string) {
    const t = text.trim()
    if (!t) return
    const r = understand(t, latest.current)
    setMsgs((m) => [...m, { role: 'me', text: t }, { role: 'ai', text: r.reply }])
    if (JSON.stringify(r.draft) !== JSON.stringify(latest.current)) {
      latest.current = r.draft
      setDraft(r.draft)
      setFormKey((k) => k + 1) // reload the form with the new values
      setSnap(emptySnap(r.draft))
    }
    if (r.review) setMode('normal')
  }

  const voice = useVoice((text, isFinal) => {
    if (isFinal) {
      setInterim('')
      send(text)
    } else {
      setInterim(text)
    }
  })

  const checks: [string, boolean][] = [
    ['Name allowed', snap.name.trim() !== '' && !isImpersonation(snap.name, snap.symbol)],
    ['Ticker set', snap.symbol.trim() !== ''],
    ['Image added', snap.image !== ''],
    ['Wallet connected', mounted && isConnected],
  ]
  const feeText = fee === undefined ? '…' : `${Number(formatEther(fee)).toLocaleString(undefined, { maximumFractionDigits: 6 })} ETH`

  return (
    <>
      <div className="x-l-head">
        <h1 className="x-h1">Launch.</h1>
        <div className="x-toggle" role="group" aria-label="Launch mode">
          <button type="button" className={mode === 'voice' ? 'on' : ''} aria-pressed={mode === 'voice'} onClick={() => setMode('voice')}><MicIcon /> Voice mode</button>
          <button type="button" className={mode === 'normal' ? 'on' : ''} aria-pressed={mode === 'normal'} onClick={() => setMode('normal')}><DocIcon /> Normal mode</button>
        </div>
      </div>

      <div className="x-l-grid">
        <div className="x-stack">
          {/* Normal mode: the existing launch form. It stays mounted while hidden so nothing typed is lost. */}
          <div hidden={mode !== 'normal'}>
            {ready && (
              <LaunchForm
                key={formKey}
                initial={draft}
                onChange={(d) => {
                  latest.current = {
                    tokenName: d.tokenName, tokenSymbol: d.tokenSymbol, description: d.description,
                    xLink: d.xLink, telegram: d.telegram, website: d.website, creatorTaxPct: d.creatorTaxPct ?? '0',
                  }
                  setSnap({ image: d.tokenImagePreview || '', name: d.tokenName, symbol: d.tokenSymbol, description: d.description, xLink: d.xLink, telegram: d.telegram, website: d.website, fee: d.creatorTaxPct ?? '0' })
                }}
              />
            )}
          </div>

          {mode === 'voice' && (
            <div className="x-convo">
              <div className="top">
                <span className={`x-live${voice.listening ? '' : ' idle'}`}>{voice.listening ? 'Listening…' : 'Tap the mic to talk'}</span>
                <span className="x-tag" style={{ background: 'rgba(255,255,255,.1)', color: '#bbb' }}>Voice mode</span>
              </div>
              <div className="x-msgs" ref={msgsRef} aria-live="polite">
                {msgs.map((m, i) => <p key={i} className={m.role}>{m.text}</p>)}
                {interim && <p className="me ghost">{interim}…</p>}
              </div>
              <form
                className="x-dock"
                onSubmit={(e) => {
                  e.preventDefault()
                  send(input)
                  setInput('')
                }}
              >
                <div className={`x-wave${voice.listening ? ' on' : ''}`} aria-hidden="true">
                  {WAVE.map((h, n) => <i key={n} style={{ height: h, animationDelay: `${n * 70}ms` }} />)}
                </div>
                <input value={input} onChange={(e) => setInput(e.target.value)} placeholder="Or type your message…" aria-label="Type your message" />
                <button type="button" className={`x-mic${voice.listening ? ' on' : ''}`} onClick={voice.toggle} aria-pressed={voice.listening} aria-label={voice.listening ? 'Stop listening' : 'Start voice input'}>
                  <MicIcon />
                </button>
              </form>
              {voice.error && <p className="x-err" role="alert">{voice.error}</p>}
            </div>
          )}
        </div>

        <div className="x-stack x-sticky">
          <div>
            <div className="x-pv-label">LIVE PREVIEW</div>
            <TokenPreview
              image={snap.image || undefined}
              name={snap.name}
              symbol={snap.symbol}
              description={snap.description}
              xLink={snap.xLink}
              telegram={snap.telegram}
              website={snap.website}
            />
          </div>
          <div className="x-chk">
            <h3>Safety checks</h3>
            <ul>
              {checks.map(([label, ok]) => (
                <li key={label} className={ok ? '' : 'off'}><CheckIcon />{label}</li>
              ))}
            </ul>
          </div>
          {mode === 'voice' && (
            <button type="button" className="x-btn big" onClick={() => { send('review') }}>Review &amp; deploy</button>
          )}
          <p className="x-fine">Launch fee {feeText} · Creator fee {snap.fee || '0'}% · Your wallet signs the transaction</p>
        </div>
      </div>
    </>
  )
}
