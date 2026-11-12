#!/usr/bin/env bash
# Run from the project root (the folder that has package.json and app/).
set -euo pipefail
[ -f package.json ] && [ -d app ] || { echo "Run this from the project root"; exit 1; }
mkdir -p lib components/landing components/launch-page app/launch
cat > 'lib/use-voice.ts' <<'IGNIO_EOF'
'use client'

import { useCallback, useEffect, useRef, useState } from 'react'

type Recognition = {
  lang: string
  interimResults: boolean
  continuous: boolean
  start(): void
  stop(): void
  onresult: ((e: { results: ArrayLike<ArrayLike<{ transcript: string }> & { isFinal: boolean }> }) => void) | null
  onend: (() => void) | null
  onerror: (() => void) | null
}
type RecognitionCtor = new () => Recognition

/** Browser speech-to-text. onText gets the running transcript and whether it is final. */
export function useVoice(onText: (text: string, isFinal: boolean) => void) {
  const [listening, setListening] = useState(false)
  const [error, setError] = useState('')
  const recRef = useRef<Recognition | null>(null)
  const cbRef = useRef(onText)

  useEffect(() => {
    cbRef.current = onText
  })
  useEffect(() => () => recRef.current?.stop(), [])

  const toggle = useCallback(() => {
    if (listening) {
      recRef.current?.stop()
      return
    }
    const w = window as unknown as { SpeechRecognition?: RecognitionCtor; webkitSpeechRecognition?: RecognitionCtor }
    const Ctor = w.SpeechRecognition || w.webkitSpeechRecognition
    if (!Ctor) {
      setError('Voice input is not supported in this browser. Type your request instead.')
      return
    }
    const rec = new Ctor()
    rec.lang = 'en-US'
    rec.interimResults = true
    rec.continuous = false
    rec.onresult = (e) => {
      const text = Array.from(e.results).map((r) => r[0].transcript).join(' ').trim()
      const last = e.results[e.results.length - 1]
      cbRef.current(text, Boolean(last?.isFinal))
    }
    rec.onend = () => setListening(false)
    rec.onerror = () => {
      setListening(false)
      setError('Could not hear you. Check microphone permission or type instead.')
    }
    recRef.current = rec
    setError('')
    setListening(true)
    rec.start()
  }, [listening])

  return { listening, error, toggle, clearError: () => setError('') }
}
IGNIO_EOF
cat > 'components/landing/logo.tsx' <<'IGNIO_EOF'
import Link from 'next/link'

export default function Logo() {
  return (
    <Link href="/" className="ig-logo" aria-label="Ignio home">
      ignio<span className="ig-ul" />
    </Link>
  )
}
IGNIO_EOF
cat > 'components/landing/landing.tsx' <<'IGNIO_EOF'
'use client'

import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useMemo, useRef, useState } from 'react'
import Logo from './logo'
import { isImpersonation, RESERVED_MESSAGE } from '@/lib/brand-guard'
import { EXAMPLE_PROMPT, launchHref, parsePrompt } from '@/lib/parse-prompt'
import { useVoice } from '@/lib/use-voice'
import './landing.css'

const WAVE = [14, 28, 40, 26, 48, 22, 40, 16, 34, 12, 22, 10]
const PILLS: [string, string][] = [
  ['Fan token', 'Create a fan token called '],
  ['Rewards', 'Create a rewards token called '],
  ['Membership', 'Create a membership token called '],
  ['Chat instead', ''],
]

export default function Landing() {
  const router = useRouter()
  const [prompt, setPrompt] = useState('')
  const [error, setError] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)

  function go(text: string) {
    const p = parsePrompt(text)
    if (isImpersonation(p.name, p.symbol)) {
      setError(RESERVED_MESSAGE)
      return
    }
    setError('')
    router.push(launchHref(p))
  }

  const voice = useVoice((text, isFinal) => {
    setPrompt(text)
    if (isFinal && /\blaunch\b/i.test(text) && parsePrompt(text).name) go(text)
  })

  const parsed = useMemo(() => parsePrompt(prompt || EXAMPLE_PROMPT), [prompt])
  const bubble = parsed.name
    ? `${parsed.name} (${parsed.symbol}) is ready to configure.`
    : 'Tell me what to create and I will fill in the launch form.'

  function pick(text: string) {
    setError('')
    voice.clearError()
    setPrompt(text)
    inputRef.current?.focus()
  }

  return (
    <div className="ig">
      <section className="ig-hero">
        <nav className="ig-nav">
          <Logo />
          <div className="ig-links">
            <Link href="/launch#launch">Tokens</Link>
            <Link href="/launch#safety">Safety</Link>
            <Link href="/launch#fees">Fees</Link>
            <Link href="/launch#launch" className="ig-login">Log in</Link>
          </div>
        </nav>

        <div className="ig-stage">
          <p className="ig-sub">Create a token with your voice or in chat. No forms, no code.</p>
          <h1 className="ig-h1">
            <span>Say it.</span>
            <span>Launch it.</span>
          </h1>
          <div className="ig-bubble" aria-live="polite">
            {bubble}
            <small>Say “launch” to continue</small>
          </div>
          <button type="button" className="ig-launch" onClick={() => go(prompt || EXAMPLE_PROMPT)}>
            Launch it
          </button>
        </div>

        <div className="ig-pills">
          {PILLS.map(([label, text]) => (
            <button key={label} type="button" className="ig-pill" onClick={() => pick(text)}>
              {label}
            </button>
          ))}
        </div>

        <form
          className="ig-bar"
          onSubmit={(e) => {
            e.preventDefault()
            go(prompt || EXAMPLE_PROMPT)
          }}
        >
          <div className={`ig-wave${voice.listening ? ' on' : ''}`} aria-hidden="true">
            {WAVE.map((h, n) => (
              <i key={n} style={{ height: h, animationDelay: `${n * 70}ms` }} />
            ))}
          </div>
          <div className="ig-field">
            {!prompt && (
              <div className="ig-ghost" aria-hidden="true">
                Create a rewards token called Spark<em>, ten million supply</em>
              </div>
            )}
            <input
              ref={inputRef}
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              aria-label="Describe the token you want to create"
              autoComplete="off"
              spellCheck={false}
            />
          </div>
          <button
            type="button"
            className={`ig-mic${voice.listening ? ' on' : ''}`}
            onClick={voice.toggle}
            aria-pressed={voice.listening}
            aria-label={voice.listening ? 'Stop listening' : 'Start voice input'}
          >
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <rect x="9" y="3" width="6" height="11" rx="3" />
              <path d="M5 11a7 7 0 0 0 14 0M12 18v3" />
            </svg>
          </button>
        </form>
        {(error || voice.error) && <p className="ig-error" role="alert">{error || voice.error}</p>}
      </section>
    </div>
  )
}
IGNIO_EOF
cat > 'components/launch-page/launch-hub.tsx' <<'IGNIO_EOF'
'use client'

import { useEffect, useRef, useState } from 'react'
import { useAccount, useReadContract } from 'wagmi'
import { formatEther, parseAbi } from 'viem'
import Logo from '@/components/landing/logo'
import { LaunchForm } from '@/components/launch-page/launch-form'
import { TokenPreview } from '@/components/launch-page/token-preview'
import { isImpersonation, RESERVED_MESSAGE } from '@/lib/brand-guard'
import { PONS_V2_FACTORY_ADDRESS } from '@/lib/hooks/use-launch-token'
import { parsePrompt } from '@/lib/parse-prompt'
import { useVoice } from '@/lib/use-voice'
import { robinhoodChain } from '@/lib/wagmi-config'
import '@/components/landing/landing.css'
import './launch-hub.css'

type Prefill = { tokenName: string; tokenSymbol: string; description: string }
type Preview = { image: string; name: string; symbol: string; description: string; xLink: string; telegram: string; website: string }

const EMPTY_PREVIEW: Preview = { image: '', name: '', symbol: '', description: '', xLink: '', telegram: '', website: '' }
const EXAMPLE = 'Create a fan token called Comet, one million supply'
const WAVE = [14, 28, 40, 26, 48, 22, 40, 16, 34, 12, 22, 10]
const TEMPLATES: [string, string][] = [
  ['Fan token', 'Fan token'],
  ['Rewards points', 'Rewards token'],
  ['Membership pass', 'Membership token'],
]
const FACTORY_ABI = parseAbi([
  'function launchFee() view returns (uint256)',
  'function maxCreatorTaxBps() view returns (uint256)',
])

export default function LaunchHub() {
  const { address, isConnected } = useAccount()
  const [initial, setInitial] = useState<Prefill | null>(null)
  const [formKey, setFormKey] = useState(0)
  const [preview, setPreview] = useState<Preview>(EMPTY_PREVIEW)
  const [prompt, setPrompt] = useState('')
  const [error, setError] = useState('')
  const areaRef = useRef<HTMLTextAreaElement>(null)

  const { data: fee } = useReadContract({ address: PONS_V2_FACTORY_ADDRESS, abi: FACTORY_ABI, functionName: 'launchFee', chainId: robinhoodChain.id })
  const { data: maxTax } = useReadContract({ address: PONS_V2_FACTORY_ADDRESS, abi: FACTORY_ABI, functionName: 'maxCreatorTaxBps', chainId: robinhoodChain.id })

  const scrollToForm = () => document.getElementById('launch')?.scrollIntoView({ behavior: 'smooth', block: 'start' })

  function prefill(p: Prefill, scroll = true) {
    setInitial(p)
    setFormKey((k) => k + 1)
    setPreview({ ...EMPTY_PREVIEW, name: p.tokenName, symbol: p.tokenSymbol, description: p.description })
    if (scroll) requestAnimationFrame(scrollToForm)
  }

  // Values handed over from the home page (/launch?name=…&symbol=…&description=…)
  useEffect(() => {
    const q = new URLSearchParams(window.location.search)
    const p: Prefill = {
      tokenName: (q.get('name') || '').slice(0, 32),
      tokenSymbol: (q.get('symbol') || '').toUpperCase().slice(0, 10),
      description: (q.get('description') || '').slice(0, 500),
    }
    prefill(p, Boolean(p.tokenName || p.tokenSymbol || p.description))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  function applyPrompt(text: string) {
    const p = parsePrompt(text || EXAMPLE)
    if (!p.name) {
      setError('Add a name, for example “Create a fan token called Comet”.')
      return
    }
    if (isImpersonation(p.name, p.symbol)) {
      setError(RESERVED_MESSAGE)
      return
    }
    setError('')
    prefill({ tokenName: p.name, tokenSymbol: p.symbol, description: p.description })
  }

  const voice = useVoice((text, isFinal) => {
    setPrompt(text)
    if (isFinal) applyPrompt(text)
  })

  const nameOk = preview.name.trim() !== '' && !isImpersonation(preview.name, preview.symbol)
  const checks: [string, boolean][] = [
    ['Name allowed', nameOk],
    ['Ticker set', preview.symbol.trim() !== ''],
    ['Image added', preview.image !== ''],
    ['Wallet connected', isConnected],
  ]

  const feeText = fee === undefined ? '…' : `${Number(formatEther(fee)).toLocaleString(undefined, { maximumFractionDigits: 6 })} ETH`
  const taxText = maxTax === undefined ? '…' : `${Number(maxTax) / 100}%`
  const stats: [string, string][] = [
    [feeText, 'launch fee'],
    [taxText, 'max creator fee'],
    [String(robinhoodChain.id), 'Robinhood Chain ID'],
  ]
  const summary: [string, string][] = [
    ['Name', preview.name || '—'],
    ['Ticker', preview.symbol || '—'],
    ['Wallet', address ? `${address.slice(0, 6)}…${address.slice(-4)}` : 'Not connected'],
    ['Network', 'Robinhood Chain'],
  ]

  return (
    <div className="ig-page">
      <div className="ig">
        <nav className="ig-nav ig-nav-paper">
          <Logo />
          <div className="ig-links">
            <a href="#launch">Tokens</a>
            <a href="#safety">Safety</a>
            <a href="#fees">Fees</a>
            <a href="#launch" className="ig-login">Log in</a>
          </div>
        </nav>

        <section className="ig-bento-wrap">
          <div className="ig-bento">
            <div className="ig-card ig-c-hero">
              <h2>
                Launch tokens
                <br />
                by talking.
              </h2>
              <a href="#launch" className="ig-btn">Start launching</a>
            </div>

            <div className="ig-card ig-c-voice">
              <div className={`ig-wave small${voice.listening ? ' on' : ''}`} aria-hidden="true">
                {WAVE.map((h, n) => (
                  <i key={n} style={{ height: h * 0.8, animationDelay: `${n * 70}ms` }} />
                ))}
              </div>
              <div className="ig-vfield">
                {!prompt && (
                  <div className="ig-vghost" aria-hidden="true">
                    Create a fan token called Comet,<em> one million supply</em>
                  </div>
                )}
                <textarea
                  ref={areaRef}
                  rows={2}
                  value={prompt}
                  onChange={(e) => setPrompt(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' && !e.shiftKey) {
                      e.preventDefault()
                      applyPrompt(prompt)
                    }
                  }}
                  aria-label="Describe the token you want to create, then press Enter"
                  spellCheck={false}
                />
              </div>
              <button
                type="button"
                className={`ig-mic big${voice.listening ? ' on' : ''}`}
                onClick={voice.toggle}
                aria-pressed={voice.listening}
                aria-label={voice.listening ? 'Stop listening' : 'Start voice input'}
              >
                <svg viewBox="0 0 24 24" aria-hidden="true">
                  <rect x="9" y="3" width="6" height="11" rx="3" />
                  <path d="M5 11a7 7 0 0 0 14 0M12 18v3" />
                </svg>
              </button>
              {(error || voice.error) && <p className="ig-err" role="alert">{error || voice.error}</p>}
            </div>

            <div className="ig-card ig-c-templates">
              <h3>Start from a template</h3>
              <ul>
                {TEMPLATES.map(([label, kind]) => (
                  <li key={label}>
                    <button
                      type="button"
                      onClick={() => prefill({ tokenName: preview.name, tokenSymbol: preview.symbol, description: preview.name ? `${kind} for ${preview.name}.` : kind })}
                    >
                      {label}
                    </button>
                  </li>
                ))}
              </ul>
            </div>

            <div className="ig-card ig-c-safety" id="safety">
              <h3>Safety checks</h3>
              <ul>
                {checks.map(([label, ok]) => (
                  <li key={label} className={ok ? '' : 'off'}>
                    <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="12" /><path d="M7 12.5l3.2 3.2L17 9" /></svg>
                    {label}
                  </li>
                ))}
              </ul>
            </div>

            <div className="ig-card ig-c-chat">
              <h3>Chat <span className="ig-tag">example</span></h3>
              <div className="ig-msgs">
                <p className="me">Make the supply two million</p>
                <p className="bot">Done. Liquidity is now 200,000 CMT.</p>
                <p className="me">Lock team tokens for a year</p>
                <p className="bot">Locked until November 2027. All 4 checks passed.</p>
              </div>
              <button type="button" className="ig-btn" onClick={() => prefill({ tokenName: 'Comet', tokenSymbol: 'CMT', description: 'Fan token for Comet.' })}>
                Launch Comet
              </button>
            </div>

            <div className="ig-card ig-c-live">
              <h3>Your launch</h3>
              <ul>
                {summary.map(([k, v]) => (
                  <li key={k}>
                    <b>{k}</b>
                    <span>{v}</span>
                  </li>
                ))}
              </ul>
            </div>

            <div className="ig-card ig-c-stats" id="fees">
              {stats.map(([value, label]) => (
                <div key={label}>
                  <strong>{value}</strong>
                  <span>{label}</span>
                </div>
              ))}
            </div>
          </div>
        </section>
      </div>

      <section className="ig-form-sec" id="launch">
        <div className="ig-form-card">
          <h2>Launch a token</h2>
          <p>Create and deploy directly through the Pons V2 factory. Your wallet signs the transaction.</p>
          <div className="pons-launch-workspace">
            <div className="pons-launch-form">
              {initial && (
                <LaunchForm
                  key={formKey}
                  initial={initial}
                  onChange={(d) =>
                    setPreview({
                      image: d.tokenImagePreview || '',
                      name: d.tokenName,
                      symbol: d.tokenSymbol,
                      description: d.description,
                      xLink: d.xLink,
                      telegram: d.telegram,
                      website: d.website,
                    })
                  }
                />
              )}
            </div>
            <aside className="pons-launch-preview">
              <div className="pons-launch-preview-label">LIVE PREVIEW</div>
              <TokenPreview
                image={preview.image || undefined}
                name={preview.name}
                symbol={preview.symbol}
                description={preview.description}
                xLink={preview.xLink}
                telegram={preview.telegram}
                website={preview.website}
              />
            </aside>
          </div>
        </div>
      </section>
    </div>
  )
}
IGNIO_EOF
cat > 'components/launch-page/launch-hub.css' <<'IGNIO_EOF'
.ig-page {
  background: #f3f4f8;
  font-family: var(--font-inter), 'Helvetica Neue', Arial, sans-serif;
  min-height: 100vh;
}
.ig-page .ig { background: transparent; }

/* nav on the light page */
.ig-nav-paper { max-width: 1528px; margin: 0 auto; padding: clamp(16px, 3vw, 32px) clamp(16px, 4.4vw, 44px) 0; }
.ig-page .ig-links a { color: #555; }
.ig-page .ig-links a.ig-login { color: #fff; background: var(--ink); }
.ig-page .ig-bento-wrap { padding-bottom: clamp(10px, 1.2vw, 16px); padding-top: clamp(14px, 2vw, 24px); }

/* shared button resets */
.ig button.ig-btn { border: 0; cursor: pointer; font-family: inherit; }
.ig .ig-card .ig-btn { transition: transform 0.15s; }
.ig .ig-card .ig-btn:hover { transform: translateY(-2px); }

/* voice card */
.ig-vfield { position: relative; grid-column: 1; min-width: 0; font-weight: 700; letter-spacing: -0.04em; line-height: 1.1; font-size: clamp(22px, 2.6vw, 40px); }
.ig-vfield textarea {
  display: block; width: 100%; resize: none; background: transparent; border: 0; outline: 0; padding: 0;
  color: var(--ink); font: inherit; letter-spacing: inherit; line-height: inherit; overflow: hidden;
}
.ig-vghost { position: absolute; inset: 0; pointer-events: none; color: var(--ink); }
.ig-vghost em { font-style: normal; color: rgba(9, 9, 9, 0.5); }
.ig-mic.big.on { box-shadow: 0 0 0 6px rgba(9, 9, 9, 0.25); }
.ig-c-voice .ig-wave.small.on i { animation-duration: 0.7s; }
.ig-err { grid-column: 1 / -1; font-size: 13px; font-weight: 600; }

/* templates as buttons */
.ig-c-templates button {
  display: block; width: 100%; text-align: left; border: 0; cursor: pointer; font-family: inherit;
  background: #fff; border-radius: 999px; padding: 0.9em 1.2em; font-weight: 600; font-size: 15px; color: var(--ink);
  transition: transform 0.15s;
}
.ig-c-templates button:hover { transform: translateX(4px); }

/* checks that are not met yet */
.ig-c-safety li { transition: opacity 0.2s; }
.ig-c-safety li.off { opacity: 0.4; }

/* summary + stats */
.ig-c-live li span { text-align: right; overflow-wrap: anywhere; padding-left: 12px; }
.ig-c-stats strong { font-size: clamp(26px, 3.2vw, 46px); white-space: nowrap; }

/* launch form section */
.ig-form-sec { padding: 0 clamp(16px, 4.4vw, 44px) clamp(16px, 4.4vw, 44px); scroll-margin-top: 12px; }
.ig-form-card { max-width: 1440px; margin: 0 auto; background: #0b0b0b; color: #f5f5f5; border-radius: 48px; padding: clamp(20px, 3.2vw, 48px); }
.ig-form-card h2 { margin: 0 0 8px; font-weight: 800; letter-spacing: -0.055em; line-height: 1; font-size: clamp(32px, 4vw, 56px); color: #fff; }
.ig-form-card > p { margin: 0 0 28px; color: #999; font-size: 14px; line-height: 1.6; }
.ig-form-card .pons-launch-workspace { max-width: none; margin: 0; }
.ig-form-card .obrix-launch-card { background: #111 !important; }
@media (max-width: 760px) {
  .ig-form-card { border-radius: 32px; }
  .ig-nav-paper .ig-links a:not(.ig-login) { display: none; }
}
IGNIO_EOF
cat > 'app/launch/page.tsx' <<'IGNIO_EOF'
import LaunchHub from '@/components/launch-page/launch-hub'

export default function LaunchPage() {
  return <LaunchHub />
}
IGNIO_EOF
echo "Done. Home (/) is the hero; /launch is the card page with the launch form."
