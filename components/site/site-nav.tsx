'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useState } from 'react'
import WalletButton from './wallet-button'
import './site.css'

export const NAV_LINKS: [string, string][] = [
  ['Explore', '/explore'],
  ['Launch', '/launch'],
  ['How It Works', '/how-it-works'],
  ['Docs', '/docs'],
  ['About', '/about'],
]

export function Logo() {
  return (
    <Link href="/" className="x-logo" aria-label="Ignio home">
      ignio<span className="x-ul" />
    </Link>
  )
}

/** Site navigation. tone="lime" is used on the home hero. */
export default function SiteNav({ tone = 'paper' }: { tone?: 'paper' | 'lime' }) {
  const path = usePathname() || ''
  const [open, setOpen] = useState(false)
  const isOn = (href: string) => path === href || path.startsWith(href + '/')

  return (
    <>
      <header className={`x-nav${tone === 'lime' ? ' x-nav-lime' : ''}`}>
        <Logo />
        <nav className="x-links" aria-label="Main">
          {NAV_LINKS.map(([name, href]) => (
            <Link key={href} href={href} className={isOn(href) ? 'on' : ''}>{name}</Link>
          ))}
        </nav>
        <WalletButton />
        <button type="button" className="x-burger" aria-label="Open menu" onClick={() => setOpen(true)}>
          <svg viewBox="0 0 24 24"><path d="M4 8h16M4 16h16" /></svg>
        </button>
      </header>

      <div className={`x-drawer${open ? ' open' : ''}`} aria-hidden={!open}>
        <div className="top">
          <Logo />
          <button type="button" className="close" aria-label="Close menu" onClick={() => setOpen(false)}>
            <svg viewBox="0 0 24 24"><path d="M5 5l14 14M19 5L5 19" /></svg>
          </button>
        </div>
        <nav aria-label="Mobile">
          {NAV_LINKS.map(([name, href], i) => (
            <Link key={href} href={href} className={isOn(href) ? 'on' : ''} onClick={() => setOpen(false)}>
              {name}
              <small>0{i + 1}</small>
            </Link>
          ))}
        </nav>
        <WalletButton block />
      </div>
    </>
  )
}
