'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useEffect, useState } from 'react'
import WalletButton from './wallet-button'
import './site.css'

export const NAV_LINKS: [string, string][] = [
  ['Explore', '/explore'],
  ['Launch', '/launch'],
  ['How It Works', '/how-it-works'],
  ['Docs', '/docs'],
  ['About', '/about'],
]

const ICONS: Record<string, React.ReactNode> = {
  '/explore': (<><circle cx="11" cy="11" r="7" /><path d="M20 20l-4-4" /></>),
  '/launch': (<><path d="M5 19c0-5 3-11 14-14 0 11-6 14-11 14z" /><path d="M9 15l-4 1M13 19l1-4" /></>),
  '/how-it-works': (<><circle cx="12" cy="12" r="9" /><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.4-1 .9-1 1.7M12 17h.01" /></>),
  '/docs': (<><path d="M6 3h8l5 5v13H6z" /><path d="M14 3v5h5M9 13h7M9 17h7" /></>),
  '/about': (<><circle cx="12" cy="8" r="4" /><path d="M4 21c0-4 3.5-7 8-7s8 3 8 7" /></>),
}

export function Logo() {
  return (
    <Link href="/" className="x-logo" aria-label="Ignio home">
      ignio<span className="x-ul" />
    </Link>
  )
}

/** Site navigation. tone="lime" is used on the home hero. On small screens the menu is a bottom sheet. */
export default function SiteNav({ tone = 'paper' }: { tone?: 'paper' | 'lime' }) {
  const path = usePathname() || ''
  const [open, setOpen] = useState(false)
  const isOn = (href: string) => path === href || path.startsWith(href + '/')

  useEffect(() => {
    if (!open) return
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && setOpen(false)
    document.addEventListener('keydown', onKey)
    const prev = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.removeEventListener('keydown', onKey)
      document.body.style.overflow = prev
    }
  }, [open])

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
        <button type="button" className="x-burger" aria-label="Open menu" aria-expanded={open} onClick={() => setOpen(true)}>
          <svg viewBox="0 0 24 24"><path d="M4 8h16M4 16h16" /></svg>
        </button>
      </header>

      <div className={`x-sheet-wrap${open ? ' open' : ''}`} aria-hidden={!open}>
        <div className="x-backdrop" onClick={() => setOpen(false)} />
        <div className="x-sheet" role="dialog" aria-modal="true" aria-label="Menu">
          <div className="handle" />
          <div className="head">
            <Logo />
            <button type="button" className="close" aria-label="Close menu" onClick={() => setOpen(false)}>
              <svg viewBox="0 0 24 24"><path d="M5 5l14 14M19 5L5 19" /></svg>
            </button>
          </div>
          <nav aria-label="Mobile">
            {NAV_LINKS.map(([name, href]) => (
              <Link key={href} href={href} className={isOn(href) ? 'on' : ''} onClick={() => setOpen(false)}>
                <span className="ico"><svg viewBox="0 0 24 24" aria-hidden="true">{ICONS[href]}</svg></span>
                {name}
                <svg className="go" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6" /></svg>
              </Link>
            ))}
          </nav>
          <WalletButton block up />
        </div>
      </div>
    </>
  )
}
