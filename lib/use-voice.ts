'use client'

import { useCallback, useEffect, useRef, useState } from 'react'

type Result = ArrayLike<{ transcript: string }> & { isFinal: boolean }
type Recognition = {
  lang: string
  interimResults: boolean
  continuous: boolean
  start(): void
  stop(): void
  onresult: ((e: { resultIndex: number; results: ArrayLike<Result> }) => void) | null
  onend: (() => void) | null
  onerror: ((e: { error?: string }) => void) | null
}
type RecognitionCtor = new () => Recognition

/**
 * Browser speech-to-text. onText gets the transcript and whether it is final.
 * With { continuous: true } it keeps listening across pauses (auto-restarts) and
 * reports each finished phrase once, until the user taps the mic again.
 */
export function useVoice(onText: (text: string, isFinal: boolean) => void, opts?: { continuous?: boolean }) {
  const continuous = Boolean(opts?.continuous)
  const [listening, setListening] = useState(false)
  const [error, setError] = useState('')
  const recRef = useRef<Recognition | null>(null)
  const wantRef = useRef(false)
  const cbRef = useRef(onText)

  useEffect(() => {
    cbRef.current = onText
  })
  useEffect(
    () => () => {
      wantRef.current = false
      recRef.current?.stop()
    },
    [],
  )

  const toggle = useCallback(() => {
    if (listening) {
      wantRef.current = false
      recRef.current?.stop()
      setListening(false)
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
    rec.continuous = continuous
    rec.onresult = (e) => {
      if (!continuous) {
        const text = Array.from(e.results).map((r) => r[0].transcript).join(' ').trim()
        const last = e.results[e.results.length - 1]
        cbRef.current(text, Boolean(last?.isFinal))
        return
      }
      let interim = ''
      for (let i = e.resultIndex; i < e.results.length; i++) {
        const r = e.results[i]
        const tx = r[0].transcript
        if (r.isFinal) {
          if (tx.trim()) cbRef.current(tx.trim(), true)
        } else {
          interim += tx
        }
      }
      if (interim.trim()) cbRef.current(interim.trim(), false)
    }
    rec.onend = () => {
      if (continuous && wantRef.current) {
        // the browser ends sessions after a pause, so start again
        setTimeout(() => {
          if (!wantRef.current) return
          try {
            rec.start()
          } catch {
            wantRef.current = false
            setListening(false)
          }
        }, 250)
        return
      }
      setListening(false)
    }
    rec.onerror = (e) => {
      const code = e?.error || ''
      if (continuous && (code === 'no-speech' || code === 'aborted')) return // onend restarts
      wantRef.current = false
      setListening(false)
      setError(
        code === 'not-allowed' || code === 'service-not-allowed'
          ? 'Microphone permission is blocked. Allow the mic for this site and try again.'
          : 'Could not hear you. Check your microphone and connection, or type instead.',
      )
    }
    recRef.current = rec
    wantRef.current = true
    setError('')
    setListening(true)
    try {
      rec.start()
    } catch {
      wantRef.current = false
      setListening(false)
    }
  }, [listening, continuous])

  return { listening, error, toggle, clearError: () => setError('') }
}
