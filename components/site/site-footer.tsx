import Link from 'next/link'

export default function SiteFooter() {
  return (
    <footer className="x-foot">
      <div className="x-wrap">
        <div className="in">
          <span>© {new Date().getFullYear()} Ignio · Built on Robinhood Chain, powered by Pons V2</span>
          <nav>
            <Link href="/explore">Explore</Link>
            <Link href="/launch">Launch</Link>
            <Link href="/docs">Docs</Link>
          </nav>
        </div>
      </div>
    </footer>
  )
}
