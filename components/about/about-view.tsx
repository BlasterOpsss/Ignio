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
