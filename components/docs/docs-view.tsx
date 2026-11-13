'use client'

import Link from 'next/link'
import { useEffect, useMemo, useRef, useState } from 'react'

type Cat = 'Guides' | 'Concepts' | 'Reference' | 'FAQ'
const CATS: ('All' | Cat)[] = ['All', 'Guides', 'Concepts', 'Reference', 'FAQ']

const ARTICLES: { title: string; cat: Cat }[] = [
  { title: 'What is a bonding curve?', cat: 'Concepts' },
  { title: 'How does graduation work?', cat: 'Concepts' },
  { title: 'Setting a creator fee', cat: 'Guides' },
  { title: 'Why was my name rejected?', cat: 'FAQ' },
  { title: 'Switching to Robinhood Chain', cat: 'Guides' },
  { title: 'Pons V2 factory: launchFee and maxCreatorTaxBps', cat: 'Reference' },
  { title: 'How Ignio launches are tagged', cat: 'Reference' },
  { title: 'What does a launch cost?', cat: 'FAQ' },
]

const I = {
  search: <><circle cx="11" cy="11" r="7" /><path d="M20 20l-4-4" /></>,
  rocket: <><path d="M5 19c0-5 3-11 14-14 0 11-6 14-11 14z" /><path d="M9 15l-4 1M13 19l1-4" /></>,
  mic: <><rect x="9" y="3" width="6" height="11" rx="3" /><path d="M5 11a7 7 0 0 0 14 0M12 18v3" /></>,
  wallet: <><path d="M3 7a2 2 0 0 1 2-2h13v4M3 7v10a2 2 0 0 0 2 2h14a1 1 0 0 0 1-1v-9a1 1 0 0 0-1-1H5a2 2 0 0 1-2-2" /></>,
  code: <><path d="M8 8l-5 4 5 4M16 8l5 4-5 4M14 5l-4 14" /></>,
  arrow: <><path d="M5 12h14M13 6l6 6-6 6" /></>,
}
const Icon = ({ d }: { d: React.ReactNode }) => <svg viewBox="0 0 24 24" aria-hidden="true">{d}</svg>

const START: { t: string; s: string; href: string; tone: string; ico: React.ReactNode }[] = [
  { t: 'Launch your first token', s: 'Step by step in two minutes', href: '/launch', tone: 'peach', ico: I.rocket },
  { t: 'Using voice mode', s: 'Say it and the form fills itself', href: '/launch?mode=voice', tone: 'lav', ico: I.mic },
  { t: 'Connect a wallet', s: 'Use Connect Wallet, then switch network', href: '/launch', tone: 'mint', ico: I.wallet },
]

export default function DocsView() {
  const [q, setQ] = useState('')
  const [cat, setCat] = useState<'All' | Cat>('All')
  const input = useRef<HTMLInputElement>(null)

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      const el = document.activeElement as HTMLElement | null
      if (e.key === '/' && el?.tagName !== 'INPUT' && el?.tagName !== 'TEXTAREA') {
        e.preventDefault()
        input.current?.focus()
      }
    }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [])

  const list = useMemo(() => {
    const n = q.trim().toLowerCase()
    return ARTICLES.filter((a) => (cat === 'All' || a.cat === cat) && (!n || a.title.toLowerCase().includes(n)))
  }, [q, cat])

  return (
    <div className="x-docs">
      <section className="x-docs-hero">
        <span className="x-docs-pill">Documentation</span>
        <h1>How can we help?</h1>
        <p>Search guides, concepts and contract references.</p>
        <label className="x-docs-search">
          <svg viewBox="0 0 24 24" aria-hidden="true">{I.search}</svg>
          <input
            ref={input}
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder={'Search "creator fee", "graduation", "factory"…'}
            aria-label="Search the docs"
            autoComplete="off"
            spellCheck={false}
          />
          <kbd>/</kbd>
        </label>
        <div className="x-docs-chips" role="tablist" aria-label="Filter">
          {CATS.map((c) => (
            <button key={c} type="button" role="tab" aria-selected={cat === c} className={cat === c ? 'on' : ''} onClick={() => setCat(c)}>
              {c}
            </button>
          ))}
        </div>
      </section>

      <section className="x-docs-sec">
        <h2>Start here</h2>
        <div className="x-docs-start">
          {START.map((s) => (
            <Link key={s.t} href={s.href} className={`x-docs-card t-${s.tone}`}>
              <span className="ico"><Icon d={s.ico} /></span>
              <span>
                <b>{s.t}</b>
                <small>{s.s}</small>
              </span>
            </Link>
          ))}
        </div>
      </section>

      <section className="x-docs-sec x-docs-pop">
        <div className="x-docs-list">
          <h2>{q || cat !== 'All' ? `Results (${list.length})` : 'Popular articles'}</h2>
          {list.length === 0 ? (
            <p className="x-docs-empty">Nothing matches that yet. Try another word.</p>
          ) : (
            list.map((a) => (
              <div key={a.title} className="x-docs-row">
                <span>{a.title}<em>{a.cat}</em></span>
                <svg viewBox="0 0 24 24" aria-hidden="true">{I.arrow}</svg>
              </div>
            ))
          )}
        </div>
        <div className="x-docs-dev">
          <span className="ico"><Icon d={I.code} /></span>
          <h2>Building on Ignio?</h2>
          <p>Read the Pons V2 factory reference, its events and how Ignio launches are tagged.</p>
          <span className="x-docs-soon">Contract reference · coming soon</span>
        </div>
      </section>
    </div>
  )
}
