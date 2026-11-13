'use client'

import { useEffect, useRef, useState } from 'react'
import { useAccount, useConnect, useDisconnect, useSwitchChain } from 'wagmi'
import { robinhoodChain } from '@/lib/wagmi-config'

const WALLET_ICON = (
  <svg viewBox="0 0 24 24" aria-hidden="true">
    <path d="M3 7a2 2 0 0 1 2-2h13v4" />
    <path d="M3 7v10a2 2 0 0 0 2 2h14a1 1 0 0 0 1-1v-9a1 1 0 0 0-1-1H5a2 2 0 0 1-2-2" />
    <circle cx="16.5" cy="13.5" r="1.2" fill="currentColor" />
  </svg>
)

/** Connect Wallet button for the nav. Uses the same wagmi connectors as the launch form. */
export default function WalletButton({ block = false }: { block?: boolean }) {
  const { address, isConnected, chain } = useAccount()
  const { connect, connectors, isPending } = useConnect()
  const { disconnect } = useDisconnect()
  const { switchChain, isPending: isSwitching } = useSwitchChain()
  const [open, setOpen] = useState(false)
  const [mounted, setMounted] = useState(false)
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => setMounted(true), [])
  useEffect(() => {
    if (!open) return
    const close = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false)
    }
    document.addEventListener('mousedown', close)
    return () => document.removeEventListener('mousedown', close)
  }, [open])

  const connected = mounted && isConnected && address
  const wrongChain = connected && chain?.id !== robinhoodChain.id

  return (
    <div className="x-wallet" ref={ref}>
      <button
        type="button"
        className={block ? 'x-btn big' : 'x-connect'}
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
      >
        {connected ? (
          <>
            <span className="dot" />
            {`${address.slice(0, 6)}…${address.slice(-4)}`}
          </>
        ) : (
          <>
            {WALLET_ICON}
            Connect Wallet
          </>
        )}
      </button>

      {open && (
        <div className="x-pop" role="menu">
          {connected ? (
            <>
              {wrongChain && (
                <button type="button" disabled={isSwitching} onClick={() => switchChain({ chainId: robinhoodChain.id })}>
                  {isSwitching ? 'Switching network…' : 'Switch to Robinhood Chain'}
                </button>
              )}
              <button type="button" onClick={() => { disconnect(); setOpen(false) }}>Disconnect</button>
            </>
          ) : (
            <>
              <p>Choose a wallet</p>
              {connectors.map((c) => (
                <button
                  key={c.uid}
                  type="button"
                  disabled={isPending}
                  onClick={() => { connect({ connector: c }); setOpen(false) }}
                >
                  {c.name}
                </button>
              ))}
            </>
          )}
        </div>
      )}
    </div>
  )
}
