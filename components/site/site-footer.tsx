import Link from 'next/link'

// Put your real links here. A social that is left empty is not shown.
const SOCIALS: { label: string; short: string; href: string }[] = [
  { label: 'X', short: 'X', href: '' },
  { label: 'Telegram', short: 'T', href: '' },
]
const EXPLORER = 'https://robinhoodchain.blockscout.com'

export default function SiteFooter() {
  const socials = SOCIALS.filter((s) => s.href)
  return (
    <footer className="x-foot">
      <div className="x-wrap">
        <div className="x-foot-grid">
          <div className="x-fc cta">
            <h2>Say it.<br />Launch it.</h2>
            <Link href="/launch" className="x-fbtn">Launch a token →</Link>
          </div>

          <div className="x-fc white">
            <h6>Product</h6>
            <div><Link href="/explore">Explore</Link><Link href="/launch">Launch</Link></div>
          </div>
          <div className="x-fc white">
            <h6>Learn</h6>
            <div><Link href="/how-it-works">How It Works</Link><Link href="/docs">Docs</Link></div>
          </div>
          <div className="x-fc lav">
            <h6>Company</h6>
            <div><Link href="/about">About</Link></div>
          </div>
          <div className="x-fc dark">
            <h6>{socials.length ? 'Follow' : 'On-chain'}</h6>
            {socials.length ? (
              <div className="soc">
                {socials.map((s) => (
                  <a key={s.label} href={s.href} target="_blank" rel="noreferrer" aria-label={s.label}>{s.short}</a>
                ))}
              </div>
            ) : (
              <div><a href={EXPLORER} target="_blank" rel="noreferrer">Block explorer ↗</a></div>
            )}
          </div>

          <div className="x-fc peach wide">
            <div>
              <Link href="/" className="x-logo" aria-label="Ignio home">ignio<span className="x-ul" /></Link>
              <p>Voice-first launches on Robinhood Chain</p>
            </div>
            <span className="chip">Powered by Pons V2</span>
          </div>
        </div>

        <div className="x-foot-legal">
          <span>© {new Date().getFullYear()} Ignio</span>
          <span>Trading tokens involves risk. Do your own research.</span>
        </div>
      </div>
    </footer>
  )
}
