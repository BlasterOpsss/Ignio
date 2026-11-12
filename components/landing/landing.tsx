'use client'

import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useEffect, useMemo, useRef, useState } from 'react'
import { isImpersonation, RESERVED_MESSAGE } from '@/lib/brand-guard'
import { EXAMPLE_PROMPT, launchHref, parsePrompt } from '@/lib/parse-prompt'
import './landing.css'

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

const WAVE = [14, 28, 40, 26, 48, 22, 40, 16, 34, 12, 22, 10]

/* ---- Sample content from the design mockup. Replace with real data before going live. ---- */
const SAMPLE_STATS = [
  { value: '12,400', label: 'tokens launched' },
  { value: '60 sec', label: 'average launch time' },
  { value: '$25', label: 'launch fee' },
]
const SAMPLE_LIVE = [
  ['NOVA', '+31.4%'],
  ['SPK', '+12.1%'],
  ['MBM', '+4.8%'],
  ['KITE', '+3.2%'],
  ['BEAN', '-2.3%'],
  ['LUME', '-6.7%'],
]
const SAFETY = ['Name available', 'Contract audit', 'Liquidity locked', 'Region supported']
const TEMPLATES = ['Fan token', 'Rewards points', 'Membership pass']
const PILLS: [string, string][] = [
  ['Fan token', 'Create a fan token called '],
  ['Rewards', 'Create a rewards token called '],
  ['Membership', 'Create a membership token called '],
  ['Chat instead', ''],
]

function Logo() {
  return (
    <Link href="/" className="ig-logo" aria-label="Ignio home">
      ignio<span className="ig-ul" />
    </Link>
  )
}

export default function Landing() {
  const router = useRouter()
  const [prompt, setPrompt] = useState('')
  const [listening, setListening] = useState(false)
  const [error, setError] = useState('')
  const [canListen, setCanListen] = useState(false)
  const inputRef = useRef<HTMLInputElement>(null)
  const recRef = useRef<Recognition | null>(null)

  useEffect(() => {
    const w = window as unknown as { SpeechRecognition?: RecognitionCtor; webkitSpeechRecognition?: RecognitionCtor }
    setCanListen(Boolean(w.SpeechRecognition || w.webkitSpeechRecognition))
    return () => recRef.current?.stop()
  }, [])

  const parsed = useMemo(() => parsePrompt(prompt || EXAMPLE_PROMPT), [prompt])

  function go(text: string) {
    const p = parsePrompt(text)
    if (isImpersonation(p.name, p.symbol)) {
      setError(RESERVED_MESSAGE)
      return
    }
    setError('')
    router.push(launchHref(p))
  }

  function toggleMic() {
    if (listening) {
      recRef.current?.stop()
      return
    }
    const w = window as unknown as { SpeechRecognition?: RecognitionCtor; webkitSpeechRecognition?: RecognitionCtor }
    const Ctor = w.SpeechRecognition || w.webkitSpeechRecognition
    if (!Ctor) {
      setError('Voice input is not supported in this browser. Type your request instead.')
      inputRef.current?.focus()
      return
    }
    const rec = new Ctor()
    rec.lang = 'en-US'
    rec.interimResults = true
    rec.continuous = false
    rec.onresult = (e) => {
      const text = Array.from(e.results).map((r) => r[0].transcript).join(' ').trim()
      setPrompt(text)
      const last = e.results[e.results.length - 1]
      if (last?.isFinal && /\blaunch\b/i.test(text) && parsePrompt(text).name) go(text)
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
  }

  function pick(text: string) {
    setError('')
    setPrompt(text)
    inputRef.current?.focus()
  }

  const bubble = parsed.name
    ? `${parsed.name} (${parsed.symbol}) is ready to configure.`
    : 'Tell me what to create and I will fill in the launch form.'

  return (
    <div className="ig">
      {/* ---------- Hero ---------- */}
      <section className="ig-hero">
        <nav className="ig-nav">
          <Logo />
          <div className="ig-links">
            <a href="#tokens">Tokens</a>
            <a href="#safety">Safety</a>
            <a href="#stats">Fees</a>
            <Link href="/launch" className="ig-login">Log in</Link>
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
          <div className={`ig-wave${listening ? ' on' : ''}`} aria-hidden="true">
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
            className={`ig-mic${listening ? ' on' : ''}`}
            onClick={toggleMic}
            aria-pressed={listening}
            aria-label={listening ? 'Stop listening' : canListen ? 'Start voice input' : 'Voice input'}
          >
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <rect x="9" y="3" width="6" height="11" rx="3" />
              <path d="M5 11a7 7 0 0 0 14 0M12 18v3" />
            </svg>
          </button>
        </form>
        {error && <p className="ig-error" role="alert">{error}</p>}
      </section>

      {/* ---------- Bento ---------- */}
      <section className="ig-bento-wrap" id="tokens">
        <div className="ig-bento">
          <div className="ig-card ig-c-hero">
            <h2>
              Launch tokens
              <br />
              by talking.
            </h2>
            <Link href="/launch" className="ig-btn">Start launching</Link>
          </div>

          <div className="ig-card ig-c-voice">
            <div className="ig-wave small" aria-hidden="true">
              {WAVE.map((h, n) => (
                <i key={n} style={{ height: h * 0.8, animationDelay: `${n * 70}ms` }} />
              ))}
            </div>
            <p>
              Create a fan token called Comet,
              <span> one million supply</span>
            </p>
            <Link href="/launch?name=Comet&symbol=COMET&description=Fan%20token%20for%20Comet." className="ig-mic big" aria-label="Try this example">
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <rect x="9" y="3" width="6" height="11" rx="3" />
                <path d="M5 11a7 7 0 0 0 14 0M12 18v3" />
              </svg>
            </Link>
          </div>

          <div className="ig-card ig-c-templates">
            <h3>Start from a template</h3>
            <ul>
              {TEMPLATES.map((t) => (
                <li key={t}>
                  <Link href={`/launch?description=${encodeURIComponent(t)}`}>{t}</Link>
                </li>
              ))}
            </ul>
          </div>

          <div className="ig-card ig-c-safety" id="safety">
            <h3>Safety checks</h3>
            <ul>
              {SAFETY.map((s) => (
                <li key={s}>
                  <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="12" /><path d="M7 12.5l3.2 3.2L17 9" /></svg>
                  {s}
                </li>
              ))}
            </ul>
          </div>

          <div className="ig-card ig-c-chat">
            <h3>Chat</h3>
            <div className="ig-msgs">
              <p className="me">Make the supply two million</p>
              <p className="bot">Done. Liquidity is now 200,000 CMT.</p>
              <p className="me">Lock team tokens for a year</p>
              <p className="bot">Locked until November 2027. All 4 checks passed.</p>
            </div>
            <Link href="/launch?name=Comet&symbol=CMT" className="ig-btn">Launch Comet</Link>
          </div>

          <div className="ig-card ig-c-live">
            <h3>Live now <span className="ig-tag">sample</span></h3>
            <ul>
              {SAMPLE_LIVE.map(([sym, chg]) => (
                <li key={sym}>
                  <b>{sym}</b>
                  <span>{chg}</span>
                </li>
              ))}
            </ul>
          </div>

          <div className="ig-card ig-c-stats" id="stats">
            {SAMPLE_STATS.map((s) => (
              <div key={s.label}>
                <strong>{s.value}</strong>
                <span>{s.label}</span>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
