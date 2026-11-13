#!/usr/bin/env bash
# Ignio: Docs page. Run from project root after apply-ignio-v2.sh
set -e
[ -f components/site/site.css ] || { echo "Run from the project root after apply-ignio-v2.sh"; exit 1; }
mkdir -p components/docs
cat > components/docs/docs-view.tsx <<'IGNIO_EOF'
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
IGNIO_EOF
cat > app/docs/page.tsx <<'IGNIO_EOF'
import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'
import DocsView from '@/components/docs/docs-view'

export const metadata: Metadata = { title: 'Docs – Ignio', description: 'Guides, concepts and contract references for Ignio.' }

export default function DocsPage() {
  return (
    <PageShell>
      <DocsView />
    </PageShell>
  )
}
IGNIO_EOF
if ! grep -q 'x-docs-hero' components/site/site.css; then cat >> components/site/site.css <<'IGNIO_EOF'

/* ---------- docs page ---------- */
.x-docs { font-family: var(--font-inter), Arial, sans-serif; color: var(--x-ink); }
.x-docs h1, .x-docs h2 { font-weight: 900; letter-spacing: -0.05em; margin: 0; }
.x-docs-hero { text-align: center; padding: 24px 0 8px; }
.x-docs-pill { display: inline-block; background: #fff; border-radius: 99px; padding: 8px 16px; font-weight: 700; font-size: 13px; }
.x-docs-hero h1 { font-size: clamp(44px, 8vw, 96px); line-height: 0.95; margin-top: 18px; }
.x-docs-hero p { font-size: 20px; color: #555; margin: 18px 0 32px; }
.x-docs-search { display: flex; align-items: center; gap: 14px; max-width: 760px; margin: 0 auto; background: #fff; border-radius: 99px; padding: 20px 28px; box-shadow: 0 18px 50px rgba(0, 0, 0, 0.08); cursor: text; }
.x-docs-search svg { width: 22px; height: 22px; flex: none; fill: none; stroke: var(--x-ink); stroke-width: 2.2; stroke-linecap: round; }
.x-docs-search input { flex: 1; min-width: 0; border: 0; outline: 0; background: transparent; font: 500 18px var(--font-inter), Arial, sans-serif; color: var(--x-ink); }
.x-docs-search kbd { background: var(--x-paper); border-radius: 10px; padding: 5px 10px; font: 600 13px var(--font-inter), Arial, sans-serif; color: #555; }
.x-docs-chips { display: flex; gap: 10px; justify-content: center; flex-wrap: wrap; margin-top: 20px; }
.x-docs-chips button { border: 0; cursor: pointer; background: #fff; color: var(--x-ink); border-radius: 99px; padding: 9px 18px; font: 600 14px var(--font-inter), Arial, sans-serif; }
.x-docs-chips button.on { background: var(--x-lime); }
.x-docs-sec { margin-top: 48px; }
.x-docs-sec h2 { font-size: 30px; margin-bottom: 20px; }
.x-docs-start { display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px; }
.x-docs-card { display: flex; align-items: center; gap: 18px; padding: 28px; border-radius: 36px 36px 36px 12px; color: var(--x-ink); text-decoration: none; transition: transform 0.15s; }
.x-docs-card:hover { transform: translateY(-3px); }
.x-docs-card b { display: block; font-size: 19px; letter-spacing: -0.03em; }
.x-docs-card small { display: block; margin-top: 4px; font-size: 14px; color: #555; line-height: 1.4; }
.x-docs-card.t-peach { background: var(--x-peach); } .x-docs-card.t-lav { background: var(--x-lav); } .x-docs-card.t-mint { background: var(--x-mint); }
.x-docs .ico { width: 46px; height: 46px; flex: none; border-radius: 50%; background: var(--x-ink); display: grid; place-items: center; }
.x-docs .ico svg { width: 22px; height: 22px; fill: none; stroke: var(--x-lime); stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.x-docs-pop { display: grid; grid-template-columns: 1.2fr 1fr; gap: 18px; }
.x-docs-list { background: #fff; border-radius: 36px 36px 36px 12px; padding: 30px; }
.x-docs-list h2 { margin-bottom: 6px; }
.x-docs-row { display: flex; justify-content: space-between; align-items: center; gap: 12px; padding: 18px 0; border-bottom: 1.5px solid #eee; font-weight: 700; font-size: 17px; }
.x-docs-row:last-child { border-bottom: 0; }
.x-docs-row em { font-style: normal; font-weight: 600; font-size: 12px; background: var(--x-paper); border-radius: 99px; padding: 3px 10px; margin-left: 10px; color: #666; }
.x-docs-row svg { width: 20px; height: 20px; flex: none; fill: none; stroke: #aaa; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.x-docs-empty { color: #777; padding: 18px 0; }
.x-docs-dev { background: var(--x-ink); color: #fff; border-radius: 36px 36px 36px 12px; padding: 30px; display: flex; flex-direction: column; align-items: flex-start; gap: 0; }
.x-docs-dev .ico { background: var(--x-lime); }
.x-docs-dev .ico svg { stroke: var(--x-ink); }
.x-docs-dev h2 { color: var(--x-lime); margin: 22px 0 10px; }
.x-docs-dev p { color: #bbb; line-height: 1.55; margin: 0 0 24px; }
.x-docs-soon { margin-top: auto; background: #1f1f1f; color: #aaa; border-radius: 99px; padding: 12px 20px; font-weight: 700; font-size: 14px; }
@media (max-width: 900px) {
  .x-docs-start, .x-docs-pop { grid-template-columns: 1fr; }
  .x-docs-search { padding: 16px 20px; } .x-docs-search kbd { display: none; }
  .x-docs-hero p { font-size: 17px; }
}
IGNIO_EOF
fi
echo "Docs page applied."
