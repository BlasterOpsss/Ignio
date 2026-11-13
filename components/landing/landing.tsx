'use client'

import { useRouter } from 'next/navigation'
import { useMemo, useRef, useState } from 'react'
import SiteNav from '@/components/site/site-nav'
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
        <SiteNav tone="lime" />

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
