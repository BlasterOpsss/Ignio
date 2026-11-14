#!/usr/bin/env bash
# Ignio: About page. Run from project root after apply-ignio-v2.sh
set -e
[ -f components/site/site.css ] || { echo "Run from the project root after apply-ignio-v2.sh"; exit 1; }
mkdir -p components/about
cat > components/about/about-view.tsx <<'IGNIO_EOF'
import Link from 'next/link'

const I = {
  mic: <><rect x="9" y="3" width="6" height="11" rx="3" /><path d="M5 11a7 7 0 0 0 14 0M12 18v3" /></>,
  book: <><path d="M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2zM4 19V5" /></>,
  shield: <><path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z" /><path d="M9 12l2 2 4-4" /></>,
  rocket: <><path d="M5 19c0-5 3-11 14-14 0 11-6 14-11 14z" /><path d="M9 15l-4 1M13 19l1-4" /></>,
}

const STEPS = [
  { t: 'You say it', s: 'Tell Ignio the name, ticker and idea by voice or in chat. It understands plain language.', tone: 'peach', ico: I.mic },
  { t: 'We fill the form', s: 'Your words become a ready launch form with image, links and an optional creator fee.', tone: 'lav', ico: I.book },
  { t: 'You review and sign', s: 'Safety checks run first. Then you confirm the launch fee and sign in your own wallet.', tone: 'mint', ico: I.shield },
  { t: 'Your token goes live', s: 'It appears on Explore and trades on a bonding curve on Robinhood Chain.', tone: 'sky', ico: I.rocket },
]

export default function AboutView() {
  return (
    <div className="x-about">
      <section className="x-about-hero">
        <h1>About<br />Ignio.</h1>
        <p>
          Launching a token should feel like sending a message. We built Ignio so that anyone with an idea can go from
          words to a live token in a couple of minutes.
        </p>
      </section>

      <ol className="x-about-tl">
        {STEPS.map((s, n) => (
          <li key={s.t} className="x-about-it">
            <span className="x-about-dot">{n + 1}</span>
            <div className={`x-about-card t-${s.tone}`}>
              <span className="ico"><svg viewBox="0 0 24 24" aria-hidden="true">{s.ico}</svg></span>
              <h3>{s.t}</h3>
              <p>{s.s}</p>
            </div>
          </li>
        ))}
      </ol>

      <div className="x-about-cta">
        <Link href="/launch" className="x-btn dark">Launch a token →</Link>
      </div>
    </div>
  )
}
IGNIO_EOF
cat > app/about/page.tsx <<'IGNIO_EOF'
import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'
import AboutView from '@/components/about/about-view'

export const metadata: Metadata = { title: 'About – Ignio', description: 'Why Ignio exists and how a launch works.' }

export default function AboutPage() {
  return (
    <PageShell>
      <AboutView />
    </PageShell>
  )
}
IGNIO_EOF
if ! grep -q 'x-about-hero' components/site/site.css; then cat >> components/site/site.css <<'IGNIO_EOF'

/* ---------- about page ---------- */
.x-about { font-family: var(--font-inter), Arial, sans-serif; color: var(--x-ink); }
.x-about-hero { display: grid; grid-template-columns: 1fr 1fr; gap: 50px; align-items: end; padding-top: 6px; }
.x-about-hero h1 { font-size: clamp(56px, 9vw, 110px); font-weight: 900; letter-spacing: -0.055em; line-height: 0.95; margin: 0; }
.x-about-hero p { font-size: 20px; line-height: 1.55; color: #444; padding-bottom: 12px; margin: 0; }
.x-about-tl { list-style: none; margin: 48px 0 0; padding: 0; position: relative; }
.x-about-tl::before { content: ""; position: absolute; left: calc(50% - 1.5px); top: 0; bottom: 0; width: 3px; background: var(--x-ink); opacity: 0.12; }
.x-about-it { display: grid; grid-template-columns: 1fr 1fr; gap: 80px; margin-bottom: 26px; position: relative; }
.x-about-it:nth-child(odd) .x-about-card { justify-self: end; }
.x-about-it:nth-child(even) .x-about-card { grid-column: 2; }
.x-about-card { max-width: 540px; border-radius: 40px 40px 40px 12px; padding: 30px; }
.x-about-card.t-peach { background: var(--x-peach); } .x-about-card.t-lav { background: var(--x-lav); }
.x-about-card.t-mint { background: var(--x-mint); } .x-about-card.t-sky { background: var(--x-sky); }
.x-about-card .ico { width: 46px; height: 46px; border-radius: 50%; background: var(--x-ink); display: grid; place-items: center; }
.x-about-card .ico svg { width: 22px; height: 22px; fill: none; stroke: var(--x-lime); stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.x-about-card h3 { font-size: 30px; letter-spacing: -0.045em; margin: 16px 0 10px; }
.x-about-card p { font-size: 16px; line-height: 1.6; color: #444; margin: 0; }
.x-about-dot { position: absolute; left: calc(50% - 22px); top: 28px; width: 44px; height: 44px; border-radius: 50%; background: var(--x-lime); border: 5px solid var(--x-paper); display: grid; place-items: center; font-weight: 900; font-size: 16px; z-index: 1; }
.x-about-cta { display: flex; justify-content: center; margin-top: 30px; }
.x-about-cta .x-btn { text-decoration: none; font-size: 17px; padding: 1em 1.8em; }
@media (max-width: 900px) {
  .x-about-hero { grid-template-columns: 1fr; gap: 18px; }
  .x-about-hero p { font-size: 17px; padding: 0; }
  .x-about-tl::before { left: 21px; }
  .x-about-it { grid-template-columns: 1fr; gap: 0; padding-left: 60px; }
  .x-about-it:nth-child(n) .x-about-card { grid-column: 1; justify-self: stretch; max-width: none; }
  .x-about-dot { left: 0; }
  .x-about-cta { justify-content: flex-start; }
}
IGNIO_EOF
fi
echo "About page applied."
