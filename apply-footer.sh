#!/usr/bin/env bash
# Ignio: bento footer. Run from project root after apply-ignio-v2.sh
set -e
[ -f components/site/site-footer.tsx ] && [ -f components/site/site.css ] || { echo "Run from the project root after apply-ignio-v2.sh"; exit 1; }
cat > components/site/site-footer.tsx <<'IGNIO_EOF'
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
IGNIO_EOF
if ! grep -q 'x-foot-grid' components/site/site.css; then
python3 - <<'PY'
p='components/site/site.css'; s=open(p).read()
s='\n'.join(l for l in s.split('\n') if not l.lstrip().startswith(('.x-foot ','.x-foot{','.x-foot nav')) and '.x-foot .in' not in l)
open(p,'w').write(s.rstrip('\n')+'\n')
PY
cat >> components/site/site.css <<'IGNIO_EOF'

/* ---------- footer (bento) ---------- */
.x-foot { margin-top: auto; padding-top: 40px; font-family: var(--font-inter), Arial, sans-serif; }
.x-foot-grid { display: grid; grid-template-columns: repeat(4, 1fr); grid-auto-rows: 150px; gap: 18px; }
.x-fc { border-radius: 36px 36px 36px 12px; padding: 26px; display: flex; flex-direction: column; justify-content: space-between; min-width: 0; color: var(--x-ink); }
.x-fc h6 { margin: 0 0 6px; font-size: 12px; letter-spacing: 0.12em; text-transform: uppercase; color: #888; }
.x-fc a { display: block; padding: 3px 0; font-size: 16px; font-weight: 700; color: inherit; text-decoration: none; }
.x-fc a:hover { text-decoration: underline; }
.x-fc.white { background: #fff; } .x-fc.lav { background: var(--x-lav); } .x-fc.peach { background: var(--x-peach); } .x-fc.dark { background: var(--x-ink); color: #fff; }
.x-fc.cta { background: var(--x-lime); grid-column: span 2; grid-row: span 2; }
.x-fc.cta h2 { margin: 0; font-size: clamp(40px, 5vw, 64px); font-weight: 900; letter-spacing: -0.06em; line-height: 0.92; }
.x-fc a.x-fbtn { display: inline-block; align-self: flex-start; background: var(--x-ink); color: var(--x-lime); font-weight: 800; font-size: 17px; padding: 14px 26px; border-radius: 99px; }
.x-fc a.x-fbtn:hover { text-decoration: none; opacity: 0.9; }
.x-fc .soc { display: flex; gap: 10px; }
.x-fc .soc a { width: 48px; height: 48px; padding: 0; border-radius: 50%; background: var(--x-lime); color: var(--x-ink); display: grid; place-items: center; font-weight: 800; }
.x-fc.dark a { color: var(--x-lime); }
.x-fc.wide { grid-column: span 4; flex-direction: row; align-items: center; }
.x-fc.wide p { margin: 6px 0 0; font-size: 14px; color: #444; }
.x-fc a.x-logo { display: inline-block; font-size: 30px; padding: 0 0 0.28em; margin: 0; }
.x-fc a.x-logo:hover { text-decoration: none; }
.x-fc .chip { font-weight: 800; font-size: 14px; background: #fff; border-radius: 99px; padding: 10px 16px; white-space: nowrap; }
.x-foot-legal { display: flex; justify-content: space-between; gap: 16px; flex-wrap: wrap; padding: 24px 0 32px; font-size: 14px; color: var(--x-muted); font-weight: 500; }
@media (max-width: 900px) {
  .x-foot-grid { grid-template-columns: 1fr 1fr; grid-auto-rows: auto; }
  .x-fc { min-height: 150px; } .x-fc.cta { grid-column: span 2; grid-row: auto; min-height: 260px; gap: 28px; }
  .x-fc.wide { grid-column: span 2; flex-wrap: wrap; gap: 14px; }
  .x-foot-legal { flex-direction: column; gap: 6px; }
}
IGNIO_EOF
fi
echo "Footer applied."
