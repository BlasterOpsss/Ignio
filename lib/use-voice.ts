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
