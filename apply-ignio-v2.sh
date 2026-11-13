#!/usr/bin/env bash
# Ignio redesign: new nav, Explore, Launch (voice + normal), blank pages. Run from the project root.
set -euo pipefail
[ -f package.json ] && [ -d app ] || { echo "Run this from the project root (folder with package.json and app/)"; exit 1; }
mkdir -p components/site components/launch components/explore app/explore app/launch app/how-it-works app/docs app/about lib
cat > 'components/site/site.css' <<'IGNIO_EOF'
/* Ignio site design system. Classes are prefixed x- ; page wrapper is .ig-site */
:root {
  --x-lime: #cdff00;
  --x-ink: #090909;
  --x-paper: #f3f4f8;
  --x-peach: #fde1d3;
  --x-mint: #d4f3e3;
  --x-lav: #e3dcfb;
  --x-sky: #d6e8ff;
  --x-muted: #6b6b72;
}

/* ---------- page wrapper (light theme + token overrides for shadcn parts) ---------- */
.ig-site {
  --background: #f3f4f8; --foreground: #090909; --card: #fff; --card-foreground: #090909;
  --primary: #090909; --primary-foreground: #cdff00; --muted: #f3f4f8; --muted-foreground: #55555c;
  --border: rgba(9, 9, 9, 0.12); --input: rgba(9, 9, 9, 0.12); --ring: #090909;
  color-scheme: light;
  min-height: 100vh; display: flex; flex-direction: column;
  background: var(--x-paper); color: var(--x-ink);
  font-family: var(--font-inter), 'Helvetica Neue', Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
}
.ig-site *, .ig-site *::before, .ig-site *::after { box-sizing: border-box; }
.ig-site a { color: inherit; text-decoration: none; }
.x-wrap { width: 100%; max-width: 1528px; margin: 0 auto; padding: 0 44px; }
.x-main { flex: 1; padding-top: 48px; padding-bottom: 72px; }
.x-blank { min-height: 62vh; }

/* ---------- nav ---------- */
.x-nav { display: flex; align-items: center; gap: 36px; padding: 28px 0 8px; font-family: var(--font-inter), 'Helvetica Neue', Arial, sans-serif; color: var(--x-ink); }
.x-nav a { color: inherit; text-decoration: none; }
.x-logo { position: relative; font-weight: 900; font-size: 38px; letter-spacing: -0.06em; line-height: 1; padding-bottom: 0.28em; margin-right: auto; }
.x-logo .x-ul { position: absolute; left: 0.1em; right: 0.1em; bottom: 0; height: 0.2em; border-radius: 99px; background: var(--x-lime); border: 0.07em solid var(--x-ink); }
.x-logo .x-ul::after { content: ''; position: absolute; right: -0.22em; top: 50%; width: 0.32em; aspect-ratio: 1; border-radius: 50%; background: var(--x-ink); transform: translateY(-50%); }
.x-links { display: flex; align-items: center; gap: 6px; font-weight: 600; font-size: 16px; }
.x-links a { padding: 0.65em 1.15em; border-radius: 999px; color: #4b4b52; transition: background 0.15s; }
.x-links a:hover { background: rgba(9, 9, 9, 0.06); }
.x-links a.on { background: var(--x-ink); color: var(--x-lime); }
.x-nav-lime .x-links a { color: var(--x-ink); }
.x-nav-lime .x-links a:hover { background: rgba(9, 9, 9, 0.08); }
.x-nav-lime .x-links a.on { color: var(--x-lime); }

.x-wallet { position: relative; }
.x-connect { display: inline-flex; align-items: center; gap: 10px; background: var(--x-ink); color: var(--x-lime); font: 700 16px var(--font-inter), Arial, sans-serif; padding: 0.9em 1.5em; border-radius: 999px; border: 0; cursor: pointer; white-space: nowrap; }
.x-connect svg { width: 18px; height: 18px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.x-connect .dot { width: 9px; height: 9px; border-radius: 50%; background: var(--x-lime); }
.x-pop { position: absolute; right: 0; top: calc(100% + 10px); z-index: 30; min-width: 250px; background: #fff; color: var(--x-ink); border-radius: 28px; padding: 10px; box-shadow: 0 18px 50px rgba(0, 0, 0, 0.18); display: flex; flex-direction: column; gap: 4px; }
.x-pop p { font-size: 12px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; color: var(--x-muted); padding: 10px 14px 4px; }
.x-pop button { text-align: left; border: 0; cursor: pointer; background: transparent; font: 600 15px var(--font-inter), Arial, sans-serif; color: var(--x-ink); padding: 0.85em 1em; border-radius: 18px; }
.x-pop button:hover { background: var(--x-paper); }
.x-pop button:disabled { opacity: 0.5; cursor: default; }
.x-burger { display: none; width: 48px; height: 48px; border-radius: 50%; border: 0; background: var(--x-ink); cursor: pointer; place-items: center; }
.x-burger svg { width: 22px; stroke: var(--x-lime); stroke-width: 2.4; stroke-linecap: round; fill: none; }

.x-drawer { display: none; position: fixed; inset: 0; z-index: 50; background: var(--x-ink); color: #fff; flex-direction: column; padding: 16px; font-family: var(--font-inter), Arial, sans-serif; overflow: auto; }
.x-drawer.open { display: flex; }
.x-drawer .top { display: flex; align-items: center; justify-content: space-between; }
.x-drawer .x-logo { color: #fff; margin: 0; }
.x-drawer .x-logo .x-ul { border-color: #fff; }
.x-drawer .x-logo .x-ul::after { background: #fff; }
.x-drawer .close { width: 48px; height: 48px; border-radius: 50%; background: var(--x-lime); border: 0; display: grid; place-items: center; cursor: pointer; }
.x-drawer .close svg { width: 20px; stroke: var(--x-ink); stroke-width: 2.6; stroke-linecap: round; fill: none; }
.x-drawer nav { margin-top: 40px; display: flex; flex-direction: column; gap: 6px; }
.x-drawer nav a { font-size: 44px; font-weight: 900; letter-spacing: -0.06em; padding: 8px 0; color: #fff; text-decoration: none; display: flex; justify-content: space-between; align-items: center; }
.x-drawer nav a.on { color: var(--x-lime); }
.x-drawer nav a small { font-size: 13px; font-weight: 600; letter-spacing: 0; opacity: 0.5; }
.x-drawer .x-btn { margin-top: auto; width: 100%; padding: 1.2em; font-size: 17px; }

/* ---------- shared ---------- */
.x-h1 { font-weight: 900; letter-spacing: -0.065em; line-height: 0.9; font-size: clamp(56px, 8vw, 120px); margin: 0; }
.x-btn { display: inline-flex; align-items: center; justify-content: center; gap: 10px; font: 700 16px var(--font-inter), Arial, sans-serif; padding: 1em 1.7em; border-radius: 999px; border: 0; cursor: pointer; background: var(--x-lime); color: var(--x-ink); }
.x-btn.dark { background: var(--x-ink); color: var(--x-lime); }
.x-btn.big { width: 100%; padding: 1.25em; font-size: 18px; }
.x-chip { display: inline-flex; align-items: center; gap: 8px; font: 600 14px var(--font-inter), Arial, sans-serif; padding: 0.7em 1.2em; border-radius: 999px; border: 2.5px solid var(--x-ink); background: transparent; color: var(--x-ink); cursor: pointer; }
.x-chip.on { background: var(--x-ink); color: var(--x-lime); }
.x-tag { font-size: 11px; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; padding: 4px 9px; border-radius: 99px; background: rgba(9, 9, 9, 0.08); }
.x-wave { display: flex; align-items: center; gap: 6px; }
.x-wave i { display: block; width: 6px; border-radius: 3px; background: var(--x-lime); animation: x-pulse 1.6s ease-in-out infinite; }
.x-wave.on i { animation-duration: 0.7s; }
@keyframes x-pulse { 50% { transform: scaleY(0.35); } }
.x-mic { width: 88px; height: 88px; border-radius: 50%; background: var(--x-lime); display: grid; place-items: center; border: 0; flex: none; cursor: pointer; box-shadow: 0 0 0 10px rgba(205, 255, 0, 0.18); }
.x-mic.on { box-shadow: 0 0 0 10px rgba(205, 255, 0, 0.4); }
.x-mic svg { width: 38px; fill: none; stroke: var(--x-ink); stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

/* ---------- explore ---------- */
.x-ex-head { display: flex; align-items: flex-end; justify-content: space-between; gap: 24px; flex-wrap: wrap; }
.x-ex-head p { max-width: 30ch; font-size: 18px; line-height: 1.4; font-weight: 500; padding-bottom: 10px; margin: 0; }
.x-search { margin-top: 34px; display: flex; align-items: center; gap: 16px; background: #fff; border-radius: 999px; padding: 10px 10px 10px 28px; }
.x-search svg { width: 22px; fill: none; stroke: var(--x-ink); stroke-width: 2.2; stroke-linecap: round; flex: none; }
.x-search input { flex: 1; min-width: 0; border: 0; outline: 0; background: transparent; font: 500 18px var(--font-inter), Arial, sans-serif; color: var(--x-ink); }
.x-search input::placeholder { color: #8a8a92; }
.x-search .count { background: var(--x-ink); color: var(--x-lime); font-weight: 700; font-size: 15px; padding: 0.9em 1.4em; border-radius: 999px; white-space: nowrap; }
.x-chips { margin-top: 20px; display: flex; gap: 10px; flex-wrap: wrap; }
.x-feat { margin-top: 28px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.x-feat-top { grid-column: span 2; background: var(--x-lime); border-radius: 48px 48px 120px 48px; padding: 30px; display: grid; grid-template-columns: 200px 1fr; gap: 28px; align-items: center; color: var(--x-ink); }
.x-feat-top .x-tile { background: var(--x-ink) !important; color: var(--x-lime); border-radius: 36px; }
.x-feat-top .x-tile::before { background: rgba(205, 255, 0, 0.14); }
.x-feat-top h2 { font-size: 44px; font-weight: 900; letter-spacing: -0.06em; line-height: 0.95; margin: 10px 0 12px; }
.x-feat-top p { font-size: 15px; line-height: 1.4; max-width: 34ch; margin: 0; }
.x-feat-top .stats { display: flex; gap: 28px; margin-top: 18px; }
.x-feat-top .stats small { display: block; font-size: 12px; opacity: 0.6; }
.x-feat-top .stats strong { font-size: 20px; font-weight: 800; letter-spacing: -0.03em; }
.x-feat-cta { grid-column: span 2; background: var(--x-ink); color: #fff; border-radius: 48px; padding: 34px; display: flex; flex-direction: column; justify-content: space-between; gap: 24px; position: relative; overflow: hidden; min-height: 220px; }
.x-feat-cta h2 { font-size: 56px; font-weight: 900; letter-spacing: -0.065em; line-height: 0.92; margin: 0; }
.x-feat-cta .x-wave { position: absolute; right: 34px; top: 34px; height: 60px; }
.x-feat-cta .x-btn { align-self: flex-start; }
.x-feat-solo .x-feat-cta { grid-column: 1 / -1; }
.x-grid { margin-top: 16px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.x-more { text-align: center; margin-top: 34px; }
.x-empty { margin-top: 16px; background: #fff; border-radius: 48px; padding: 56px 34px; text-align: center; }
.x-empty h3 { font-size: 28px; font-weight: 900; letter-spacing: -0.05em; margin: 0 0 8px; }
.x-empty p { color: var(--x-muted); margin: 0 0 22px; }

.x-tile { aspect-ratio: 1; border-radius: 28px; display: grid; place-items: center; font-weight: 900; letter-spacing: -0.06em; position: relative; overflow: hidden; }
.x-tile b { font-size: 96px; line-height: 1; position: relative; z-index: 1; }
.x-tile img { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; z-index: 2; }
.x-tile::before { content: ''; position: absolute; width: 70%; aspect-ratio: 1; border-radius: 50%; background: rgba(255, 255, 255, 0.45); right: -18%; bottom: -22%; }
.x-tile.t0 { background: var(--x-lime); } .x-tile.t1 { background: var(--x-peach); } .x-tile.t2 { background: var(--x-lav); }
.x-tile.t3 { background: var(--x-sky); } .x-tile.t4 { background: var(--x-mint); } .x-tile.t5 { background: #ffe98a; }
.x-tk { display: block; background: #fff; border-radius: 36px; padding: 14px; transition: transform 0.15s; }
.x-tk:hover { transform: translateY(-4px); }
.x-tk .x-tile b { font-size: 72px; }
.x-tk .meta { padding: 16px 8px 8px; }
.x-tk .row { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.x-tk h3 { font-size: 20px; font-weight: 800; letter-spacing: -0.03em; margin: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.x-tk .sym { font-size: 12px; font-weight: 700; color: var(--x-muted); background: var(--x-paper); padding: 4px 10px; border-radius: 99px; flex: none; }
.x-tk .nums { margin-top: 14px; display: flex; justify-content: space-between; align-items: flex-end; gap: 10px; }
.x-tk .nums small { display: block; font-size: 12px; color: var(--x-muted); margin-bottom: 2px; }
.x-tk .nums strong { font-size: 18px; font-weight: 800; letter-spacing: -0.02em; }
.x-bar { margin-top: 14px; height: 8px; border-radius: 99px; background: var(--x-paper); overflow: hidden; }
.x-bar span { display: block; height: 100%; border-radius: 99px; background: var(--x-ink); }
.x-tk .by { margin-top: 14px; padding-top: 12px; border-top: 1px solid #eee; font-size: 12px; color: var(--x-muted); display: flex; justify-content: space-between; gap: 8px; }
.x-skel .x-tile { background: #e9eaf0; } .x-skel .x-tile::before { display: none; }
.x-skel .line { height: 14px; border-radius: 99px; background: #e9eaf0; margin: 16px 8px 8px; }

/* ---------- launch ---------- */
.x-l-head { display: flex; align-items: center; justify-content: space-between; gap: 24px; flex-wrap: wrap; }
.x-l-head .x-h1 { font-size: clamp(56px, 7vw, 104px); }
.x-toggle { display: inline-flex; background: #fff; border-radius: 999px; padding: 6px; }
.x-toggle button { display: inline-flex; align-items: center; gap: 10px; padding: 0.95em 1.7em; border-radius: 999px; border: 0; background: transparent; cursor: pointer; font: 700 16px var(--font-inter), Arial, sans-serif; color: #555; }
.x-toggle button svg { width: 18px; fill: none; stroke: currentColor; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }
.x-toggle button.on { background: var(--x-ink); color: var(--x-lime); }
.x-l-grid { margin-top: 28px; display: grid; grid-template-columns: 7fr 5fr; gap: 16px; align-items: start; }
.x-stack { display: flex; flex-direction: column; gap: 16px; min-width: 0; }
.x-sticky { position: sticky; top: 16px; }
.x-pv-label { font-size: 12px; font-weight: 700; letter-spacing: 0.14em; color: var(--x-muted); padding: 0 8px 12px; }
.x-chk { background: var(--x-mint); border-radius: 48px 120px 48px 48px; padding: 28px 34px; }
.x-chk h3 { font-size: 18px; font-weight: 700; margin: 0 0 16px; }
.x-chk ul { list-style: none; margin: 0; padding: 0; }
.x-chk li { display: flex; align-items: center; gap: 12px; font-weight: 500; font-size: 16px; padding: 6px 0; transition: opacity 0.2s; }
.x-chk li.off { opacity: 0.4; }
.x-chk svg { width: 26px; height: 26px; flex: none; } .x-chk circle { fill: var(--x-ink); }
.x-chk path { fill: none; stroke: #fff; stroke-width: 2.4; stroke-linecap: round; stroke-linejoin: round; }
.x-fine { text-align: center; font-size: 13px; color: var(--x-muted); margin: 0; }

/* voice conversation */
.x-convo { background: var(--x-ink); color: #fff; border-radius: 48px; padding: 34px; min-height: 780px; display: flex; flex-direction: column; }
.x-convo .top { display: flex; align-items: center; justify-content: space-between; }
.x-live { display: inline-flex; align-items: center; gap: 10px; font-weight: 600; font-size: 14px; color: var(--x-lime); }
.x-live::before { content: ''; width: 10px; height: 10px; border-radius: 50%; background: var(--x-lime); box-shadow: 0 0 0 5px rgba(205, 255, 0, 0.25); }
.x-live.idle { color: #888; } .x-live.idle::before { background: #666; box-shadow: none; }
.x-msgs { flex: 1; display: flex; flex-direction: column; gap: 14px; padding: 34px 0; overflow-y: auto; max-height: 560px; }
.x-msgs > :first-child { margin-top: auto; }
.x-msgs p { max-width: 78%; padding: 16px 22px; border-radius: 26px; font-size: 19px; line-height: 1.35; font-weight: 500; letter-spacing: -0.01em; margin: 0; }
.x-msgs .ai { align-self: flex-start; background: #1d1d1f; border-bottom-left-radius: 8px; }
.x-msgs .me { align-self: flex-end; background: var(--x-lime); color: var(--x-ink); font-weight: 600; border-bottom-right-radius: 8px; }
.x-msgs .me.ghost { background: transparent; border: 2px dashed rgba(205, 255, 0, 0.5); color: var(--x-lime); }
.x-dock { background: #161617; border-radius: 999px; padding: 12px 12px 12px 36px; display: flex; align-items: center; gap: 22px; }
.x-dock .x-wave { height: 56px; flex: none; }
.x-dock input { flex: 1; min-width: 0; background: transparent; border: 0; outline: 0; color: #fff; font: 500 18px var(--font-inter), Arial, sans-serif; }
.x-dock input::placeholder { color: #8d8d92; }
.x-err { color: #ff9b9b; font-size: 14px; font-weight: 600; margin: 10px 0 0 6px; min-height: 0; }

/* ---------- launch form skin (logic lives in launch-form.tsx) ---------- */
.x-lform { display: flex; flex-direction: column; gap: 16px; }
.x-fsec { border-radius: 48px; padding: 32px 34px; }
.x-fsec h3 { font-size: 20px; font-weight: 800; letter-spacing: -0.03em; margin: 0 0 4px; }
.x-fsec .sub { font-size: 14px; color: #55555c; margin: 0 0 20px; }
.x-fs-image { background: var(--x-peach); } .x-fs-details { background: #fff; }
.x-fs-links { background: var(--x-lav); } .x-fs-fee { background: var(--x-sky); }
.x-fsec .field { margin-bottom: 16px; } .x-fsec .field:last-child { margin-bottom: 0; }
.x-fsec .two { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 16px; }
.x-fsec .two .field { margin-bottom: 0; }
.x-fsec label { font-size: 14px; font-weight: 700; color: var(--x-ink); display: block; margin-bottom: 8px; }
.ig-site .x-fsec input, .ig-site .x-fsec textarea {
  width: 100%; background: var(--x-paper) !important; color: var(--x-ink) !important; border: 2px solid transparent !important;
  border-radius: 20px !important; height: 58px !important; padding: 0 22px !important; font-size: 16px !important; font-weight: 500; box-shadow: none !important;
  font-family: inherit !important;
}
.ig-site .x-fsec textarea { height: auto !important; min-height: 120px; padding: 18px 22px !important; line-height: 1.4; resize: vertical; }
.ig-site .x-fsec input::placeholder, .ig-site .x-fsec textarea::placeholder { color: #8a8a92; }
.ig-site .x-fs-links input, .ig-site .x-fs-fee input { background: #fff !important; }
.ig-site .x-fsec input:focus, .ig-site .x-fsec textarea:focus { border-color: var(--x-ink) !important; outline: 0; }
.ig-site .x-fsec .text-xs, .ig-site .x-fsec .text-zinc-500, .ig-site .x-fsec .text-muted-foreground { color: #55555c !important; font-size: 13px; line-height: 1.5; margin-top: 8px; }
.ig-site .x-fsec .obrix-x-chips { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 14px; }
.ig-site .x-fsec .obrix-x-chips button { border: 0; border-radius: 999px; padding: 0.7em 1.4em; background: #fff; color: var(--x-ink); font-weight: 700; font-size: 15px; cursor: pointer; }
.ig-site .x-fsec .obrix-x-chips button.is-on { background: var(--x-ink); color: var(--x-lime); }
.x-fs-image [class*='border-dashed'] { max-width: none !important; border-radius: 32px !important; border: 3px dashed rgba(9, 9, 9, 0.35) !important; background: rgba(255, 255, 255, 0.55); }
.x-fs-image [class*='border-dashed'] svg { color: var(--x-ink); }
.x-fs-image .upl { margin-top: 10px; font-size: 13px; color: #55555c; }
.x-fs-submit { display: flex; flex-direction: column; gap: 12px; padding: 4px 0 0; }
.ig-site .obrix-button { background: var(--x-lime) !important; color: var(--x-ink) !important; border: 0 !important; border-radius: 999px !important; height: 64px !important; font-size: 18px !important; font-weight: 800; }
.ig-site .x-fs-submit .x-note { text-align: center; color: #b3261e; font-size: 14px; font-weight: 600; }
.ig-site .neon-glow { box-shadow: none; }

/* token preview card skin */
.ig-site .obrix-x-card { background: #fff; color: var(--x-ink); border: 0; border-radius: 48px; padding: 26px; }
.ig-site .obrix-x-avatar { width: 64px; height: 64px; border-radius: 22px; background: var(--x-lime); font-weight: 900; font-size: 28px; color: var(--x-ink); }
.ig-site .obrix-x-card-title strong { color: var(--x-ink); font-size: 22px; letter-spacing: -0.04em; font-weight: 900; }
.ig-site .obrix-x-card-title span, .ig-site .obrix-x-desc, .ig-site .obrix-x-rows dt { color: #55555c; }
.ig-site .obrix-x-desc { font-size: 15px; }
.ig-site .obrix-x-badge { background: var(--x-paper); color: var(--x-ink); padding: 4px 9px; border-radius: 99px; font-style: normal; font-weight: 700; }
.ig-site .obrix-x-rows div { border-top: 1px solid #eee; font-size: 13px; }
.ig-site .obrix-x-rows dd { color: var(--x-ink); font-weight: 600; }
.ig-site .obrix-x-actions a { background: var(--x-paper); color: var(--x-ink); font-weight: 600; padding: 0.55em 1em; border-radius: 999px; }
.ig-site .obrix-x-note-box { background: var(--x-paper); border: 0; color: #55555c; border-radius: 20px; }

/* wallet buttons inside the form */
.x-wbtns { display: flex; flex-direction: column; gap: 10px; }
.x-wbtns button, .ig-site .x-wbtn { border: 0; cursor: pointer; border-radius: 999px; padding: 1.1em 1.5em; background: var(--x-lime); color: var(--x-ink); font: 800 17px var(--font-inter), Arial, sans-serif; }
.x-wbtns button.alt { background: var(--x-ink); color: var(--x-lime); }
.x-wbtns button:disabled { opacity: 0.6; cursor: default; }
.x-wconn { text-align: center; font-size: 14px; color: #55555c; margin: 0; }
.x-wconn code { color: var(--x-ink); font-weight: 700; }

/* footer */
.x-foot { margin-top: auto; }
.x-foot .in { display: flex; justify-content: space-between; align-items: center; gap: 16px; flex-wrap: wrap; padding-top: 24px; padding-bottom: 32px; border-top: 2px solid rgba(9, 9, 9, 0.1); font-size: 14px; color: var(--x-muted); font-weight: 500; }
.x-foot nav { display: flex; gap: 22px; }

/* ---------- responsive ---------- */
@media (max-width: 1100px) {
  .x-links { display: none; } .x-nav { gap: 12px; } .x-burger { display: grid; }
  .x-grid { grid-template-columns: repeat(2, 1fr); }
  .x-feat { grid-template-columns: 1fr; } .x-feat-top, .x-feat-cta { grid-column: auto; }
  .x-l-grid { grid-template-columns: 1fr; } .x-convo { min-height: 640px; } .x-sticky { position: static; }
}
@media (max-width: 700px) {
  .x-wrap { padding: 0 16px; }
  .x-nav { padding-top: 16px; } .x-logo { font-size: 30px; }
  .x-connect { padding: 0.75em 1.1em; font-size: 14px; } .x-connect svg { display: none; }
  .x-main { padding-top: 32px; padding-bottom: 48px; }
  .x-ex-head p { font-size: 15px; }
  .x-search { margin-top: 22px; padding: 6px 6px 6px 20px; } .x-search input { font-size: 15px; } .x-search .count { display: none; }
  .x-chips { flex-wrap: nowrap; overflow-x: auto; margin-right: -16px; padding-bottom: 4px; }
  .x-chip { white-space: nowrap; font-size: 13px; padding: 0.6em 1.1em; }
  .x-feat-top { grid-template-columns: 96px 1fr; padding: 20px; gap: 16px; border-radius: 36px 36px 80px 36px; }
  .x-feat-top .x-tile b { font-size: 44px; } .x-feat-top h2 { font-size: 30px; } .x-feat-top .stats { gap: 16px; } .x-feat-top p { display: none; }
  .x-feat-cta { padding: 24px; border-radius: 36px; } .x-feat-cta h2 { font-size: 38px; } .x-feat-cta .x-wave { display: none; }
  .x-grid { gap: 10px; } .x-tk { padding: 8px; border-radius: 26px; } .x-tk .x-tile { border-radius: 20px; } .x-tk .x-tile b { font-size: 48px; }
  .x-tk h3 { font-size: 16px; } .x-tk .nums strong { font-size: 15px; } .x-tk .by { display: none; } .x-tk .sym { display: none; }
  .x-toggle { width: 100%; } .x-toggle button { flex: 1; justify-content: center; padding: 0.9em 1em; }
  .x-l-head .x-h1 { font-size: 56px; }
  .x-convo { padding: 22px; border-radius: 36px; min-height: 600px; } .x-msgs p { font-size: 16px; max-width: 88%; padding: 13px 18px; }
  .x-mic { width: 64px; height: 64px; box-shadow: 0 0 0 6px rgba(205, 255, 0, 0.18); } .x-mic svg { width: 28px; }
  .x-dock { padding: 8px 8px 8px 20px; gap: 12px; } .x-dock .x-wave { display: none; } .x-dock input { font-size: 15px; }
  .x-chk { border-radius: 36px; } .ig-site .obrix-x-card { border-radius: 36px; }
  .x-fsec { border-radius: 36px; padding: 24px 20px; } .x-fsec .two { grid-template-columns: 1fr; }
  .x-foot .in { flex-direction: column; align-items: flex-start; }
}
@media (prefers-reduced-motion: reduce) { .x-wave i { animation: none; } }
IGNIO_EOF
cat > 'components/site/wallet-button.tsx' <<'IGNIO_EOF'
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
IGNIO_EOF
cat > 'components/site/site-nav.tsx' <<'IGNIO_EOF'
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
IGNIO_EOF
cat > 'components/site/site-footer.tsx' <<'IGNIO_EOF'
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
IGNIO_EOF
cat > 'components/site/page-shell.tsx' <<'IGNIO_EOF'
import SiteNav from './site-nav'
import SiteFooter from './site-footer'

/** Common frame for every light-theme page: nav, content, footer. */
export default function PageShell({ children, blank = false }: { children?: React.ReactNode; blank?: boolean }) {
  return (
    <div className="ig-site">
      <div className="x-wrap">
        <SiteNav />
      </div>
      <main className={`x-wrap x-main${blank ? ' x-blank' : ''}`}>{children}</main>
      <SiteFooter />
    </div>
  )
}
IGNIO_EOF
cat > 'lib/ignio-tokens.ts' <<'IGNIO_EOF'
'use client'

import { useEffect, useRef, useState } from 'react'
import { usePublicClient } from 'wagmi'
import { decodeFunctionData, formatEther, formatUnits, toHex, type Address } from 'viem'
import { robinhoodChain } from '@/lib/wagmi-config'
import { PONS_V2_FACTORY_ABI } from '@/lib/abi/factory'
import { ERC20_SUPPLY_ABI, PONS_CURVE_ABI } from '@/lib/abi/curve'
import { PONS_V2_FACTORY_ADDRESS } from '@/lib/hooks/use-launch-token'

// TokenLaunched(address indexed token, address indexed curve, address indexed deployer, address pairToken)
const LAUNCH_TOPIC = '0x8d4aad4953d0ca700d468f3753aa14432d1b35b43ec6409f051fb6aa43a89607'
// Launches made through Ignio start their salt with the ASCII bytes of "IGNIO" (see use-launch-token.ts).
const IGNIO_SALT_PREFIX = '0x49474e494f'
const STEP = 1_000_000n
const FALLBACK_STEP = 100_000n

type Client = NonNullable<ReturnType<typeof usePublicClient>>
type RawLog = { topics: string[]; data: string; blockNumber: string; transactionHash: string; logIndex: string }

export interface IgnioToken {
  token: Address
  curve: Address
  creator: string
  block: bigint
  ts: number
  name: string
  symbol: string
  logo: string
  description: string
  marketCapEth: number | null
  progress: number | null
  graduated: boolean
}

export const resolveUri = (uri: string) => (uri.startsWith('ipfs://') ? `https://ipfs.io/ipfs/${uri.slice(7)}` : uri)

async function rawLogs(client: Client, from: bigint, to: bigint): Promise<RawLog[]> {
  const call = (f: bigint, t: bigint) =>
    client.request({
      method: 'eth_getLogs',
      params: [{ address: PONS_V2_FACTORY_ADDRESS, fromBlock: toHex(f), toBlock: toHex(t), topics: [LAUNCH_TOPIC] }],
    } as never) as unknown as Promise<RawLog[]>
  try {
    return await call(from, to)
  } catch {
    // The RPC refused the wide range: read it in smaller pieces.
    const out: RawLog[] = []
    for (let f = from; f <= to; f += FALLBACK_STEP) {
      const t = f + FALLBACK_STEP - 1n > to ? to : f + FALLBACK_STEP - 1n
      try { out.push(...(await call(f, t))) } catch { /* skip a failed piece */ }
    }
    return out
  }
}

async function readMarket(client: Client, token: Address, curve: Address) {
  try {
    const [reserves, real, threshold, graduated, ready, native, supply, dec] = await Promise.all([
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'getReserves' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'realQuoteReserve' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'graduationThreshold' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'graduated' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'readyToGraduate' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'isNativeQuote' }),
      client.readContract({ address: token, abi: ERC20_SUPPLY_ABI, functionName: 'totalSupply' }),
      client.readContract({ address: token, abi: ERC20_SUPPLY_ABI, functionName: 'decimals' }),
    ])
    const decimals = Number(dec)
    const price = Number(formatEther(reserves[0])) / Number(formatUnits(reserves[1], decimals))
    const marketCapEth = native ? price * Number(formatUnits(supply, decimals)) : null
    const progress = threshold > 0n ? Math.min(100, Number((real * 10000n) / threshold) / 100) : 0
    return { marketCapEth: marketCapEth !== null && isFinite(marketCapEth) ? marketCapEth : null, progress, graduated: graduated || ready }
  } catch {
    return { marketCapEth: null, progress: null as number | null, graduated: false }
  }
}

// Returns the token only when the launch transaction came from Ignio.
async function readLaunch(client: Client, log: RawLog): Promise<IgnioToken | null> {
  try {
    const tx = (await client.request({ method: 'eth_getTransactionByHash', params: [log.transactionHash] } as never)) as unknown as { input?: string } | null
    if (!tx?.input) return null
    const dec = decodeFunctionData({ abi: PONS_V2_FACTORY_ABI, data: tx.input as `0x${string}` })
    if (dec.functionName !== 'launchToken') return null
    const p = (dec.args as unknown as readonly Record<string, unknown>[])[0] as Record<string, unknown>
    if (!String(p.salt ?? '').toLowerCase().startsWith(IGNIO_SALT_PREFIX)) return null

    const token = ('0x' + log.topics[1].slice(26)) as Address
    const curve = ('0x' + log.topics[2].slice(26)) as Address
    const block = BigInt(log.blockNumber)
    const [market, blk] = await Promise.all([
      readMarket(client, token, curve),
      client.getBlock({ blockNumber: block }).catch(() => null),
    ])
    return {
      token, curve, creator: '0x' + log.topics[3].slice(26), block,
      ts: blk ? Number(blk.timestamp) : 0,
      name: String(p.name ?? ''), symbol: String(p.symbol ?? ''), logo: String(p.logo ?? ''), description: String(p.description ?? ''),
      ...market,
    }
  } catch {
    return null
  }
}

/**
 * Lists tokens launched through Ignio, newest first.
 * Scans the factory's TokenLaunched events backwards until `target` Ignio tokens are found.
 */
export function useIgnioTokens(target: number) {
  const client = usePublicClient({ chainId: robinhoodChain.id })
  const [tokens, setTokens] = useState<IgnioToken[]>([])
  const [status, setStatus] = useState<'loading' | 'ready' | 'done' | 'error'>('loading')
  const cursor = useRef<bigint | null>(null) // end of the next window to scan; -1n when finished
  const busy = useRef(false)
  const found = useRef(0)
  const targetRef = useRef(target)
  targetRef.current = target

  useEffect(() => {
    if (!client || busy.current) return
    busy.current = true
    setStatus('loading')
    ;(async () => {
      try {
        if (cursor.current === null) cursor.current = await client.getBlockNumber()
        let windows = 0
        while (cursor.current >= 0n && found.current < targetRef.current && windows < 80) {
          windows++
          const to = cursor.current
          const from = to >= STEP ? to - STEP + 1n : 0n
          cursor.current = from === 0n ? -1n : from - 1n
          const logs = (await rawLogs(client, from, to)).reverse()
          for (let i = 0; i < logs.length; i += 6) {
            const part = (await Promise.all(logs.slice(i, i + 6).map((l) => readLaunch(client, l)))).filter((t): t is IgnioToken => t !== null)
            if (part.length) {
              found.current += part.length
              setTokens((prev) => [...prev, ...part.filter((n) => !prev.some((o) => o.token === n.token))])
            }
          }
        }
        setStatus(cursor.current < 0n ? 'done' : 'ready')
      } catch {
        setStatus('error')
      } finally {
        busy.current = false
      }
    })()
  }, [client, target])

  return { tokens, status }
}
IGNIO_EOF
cat > 'lib/voice-chat.ts' <<'IGNIO_EOF'
import { isImpersonation, RESERVED_MESSAGE } from '@/lib/brand-guard'
import { parsePrompt } from '@/lib/parse-prompt'

export type Draft = {
  tokenName: string
  tokenSymbol: string
  description: string
  xLink: string
  telegram: string
  website: string
  creatorTaxPct: string
}
export type Msg = { role: 'ai' | 'me'; text: string }

export const EMPTY_DRAFT: Draft = { tokenName: '', tokenSymbol: '', description: '', xLink: '', telegram: '', website: '', creatorTaxPct: '0' }
export const GREETING =
  'What do you want to create? Say or type something like “Create a rewards token called Spark”.'

const REVIEW = /\b(launch|deploy|review|done|ready|continue|next|finish)\b/i

/**
 * Rule-based conversation: reads what the person said, updates the draft, and answers
 * with what it understood and what is still missing. It never sends a transaction.
 */
export function understand(text: string, draft: Draft): { draft: Draft; reply: string; review: boolean } {
  const t = text.trim()
  const next: Draft = { ...draft }
  const done: string[] = []

  // 1) name, ticker, description
  const p = parsePrompt(t)
  if (p.name) {
    if (isImpersonation(p.name, p.symbol)) return { draft, reply: RESERVED_MESSAGE, review: false }
    next.tokenName = p.name
    next.tokenSymbol = p.symbol
    next.description = p.description
    done.push(`${p.name} (${p.symbol})`)
  }
  const tick = t.match(/\b(?:ticker|symbol)\s+(?:is\s+)?([A-Za-z0-9]{2,10})\b/i)
  if (tick) {
    if (isImpersonation(next.tokenName, tick[1])) return { draft, reply: RESERVED_MESSAGE, review: false }
    next.tokenSymbol = tick[1].toUpperCase()
    done.push(`ticker ${next.tokenSymbol}`)
  }
  const desc = t.match(/\bdescription\s*(?:is|:)?\s+(.+)$/i)
  if (desc) {
    next.description = desc[1].trim().slice(0, 500)
    done.push('description')
  }

  // 2) links
  const x = t.match(/(?:x\.com\/|twitter\.com\/|@)([A-Za-z0-9_]{1,15})\b/i)
  if (x) { next.xLink = `x.com/${x[1]}`; done.push('X link') }
  const tg = t.match(/t\.me\/([A-Za-z0-9_]+)/i)
  if (tg) { next.telegram = `t.me/${tg[1]}`; done.push('Telegram') }
  const web = t.match(/https?:\/\/[^\s,]+|\b[a-z0-9-]+\.(?:com|xyz|io|app|org|net|gg|fun)\b(?:\/[^\s,]*)?/i)
  if (web && !/x\.com|twitter\.com|t\.me/i.test(web[0])) { next.website = web[0]; done.push('website') }

  // 3) creator fee
  const fee = t.match(/(\d+(?:\.\d+)?)\s*(?:%|percent)\s*(?:creator\s*)?fee|creator\s*fee\s*(?:of|to|is)?\s*(\d+(?:\.\d+)?)/i)
  if (fee) { next.creatorTaxPct = fee[1] ?? fee[2]; done.push(`creator fee ${next.creatorTaxPct}%`) }

  const wantsReview = REVIEW.test(t)

  if (wantsReview && !next.tokenName) {
    return { draft: next, reply: 'I need a name first. Try “Create a fan token called Comet”.', review: false }
  }
  if (wantsReview && next.tokenName) {
    return {
      draft: next,
      reply: `Opening the form for ${next.tokenName}. Add your image, check the details, then deploy. Your wallet signs the transaction.`,
      review: true,
    }
  }
  if (!done.length) {
    return {
      draft: next,
      reply: next.tokenName
        ? 'I did not catch a change. You can say a ticker, a description, links like “my X is @handle”, a creator fee like “1% fee”, or “review” when you are ready.'
        : 'I need a name to start. Try “Create a rewards token called Spark”.',
      review: false,
    }
  }
  const missing = [!next.xLink && 'an X link'].filter(Boolean)
  return {
    draft: next,
    reply: `Got it: ${done.join(', ')}. ${missing.length ? `You can still add ${missing.join(' and ')} (say “my X is @handle”). ` : ''}Say “review” when you are ready to add the image and deploy.`,
    review: false,
  }
}
IGNIO_EOF
cat > 'components/explore/explore-view.tsx' <<'IGNIO_EOF'
'use client'

import Link from 'next/link'
import { useMemo, useState } from 'react'
import { resolveUri, useIgnioTokens, type IgnioToken } from '@/lib/ignio-tokens'
import { useEthUsd } from '@/lib/token-data'

const PAGE = 12
const WAVE = [14, 28, 40, 26, 48, 22, 40, 16, 34, 12, 22, 10]
const FILTERS = ['All', 'Newest', 'Top market cap', 'Near graduation'] as const
type Filter = (typeof FILTERS)[number]

const short = (a: string) => `${a.slice(0, 6)}…${a.slice(-4)}`

function ago(ts: number) {
  if (!ts) return ''
  const s = Math.max(0, Math.floor(Date.now() / 1000 - ts))
  if (s < 3600) return `${Math.max(1, Math.floor(s / 60))}m ago`
  if (s < 86400) return `${Math.floor(s / 3600)}h ago`
  return `${Math.floor(s / 86400)}d ago`
}

function money(eth: number | null, usd: number | null) {
  if (eth === null) return '—'
  if (usd) {
    const v = eth * usd
    return v >= 1e6 ? `$${(v / 1e6).toFixed(2)}M` : v >= 1e3 ? `$${(v / 1e3).toFixed(1)}K` : `$${v.toFixed(0)}`
  }
  return `${eth >= 1 ? eth.toFixed(2) : eth.toPrecision(2)} ETH`
}

function Tile({ t, i }: { t: IgnioToken; i: number }) {
  const [broken, setBroken] = useState(false)
  return (
    <div className={`x-tile t${i % 6}`}>
      <b>{(t.symbol || t.name || '?').slice(0, 1).toUpperCase()}</b>
      {t.logo && !broken && (
        // eslint-disable-next-line @next/next/no-img-element
        <img src={resolveUri(t.logo)} alt={`${t.symbol} logo`} onError={() => setBroken(true)} loading="lazy" />
      )}
    </div>
  )
}

function TokenCard({ t, i, usd }: { t: IgnioToken; i: number; usd: number | null }) {
  return (
    <a className="x-tk" href={`https://robinhoodchain.blockscout.com/token/${t.token}`} target="_blank" rel="noreferrer">
      <Tile t={t} i={i} />
      <div className="meta">
        <div className="row"><h3>{t.name}</h3><span className="sym">{t.symbol}</span></div>
        <div className="nums">
          <div><small>Market cap</small><strong>{money(t.marketCapEth, usd)}</strong></div>
          <div style={{ textAlign: 'right' }}><small>Curve</small><strong>{t.graduated ? 'Graduated' : t.progress === null ? '—' : `${t.progress.toFixed(0)}%`}</strong></div>
        </div>
        <div className="x-bar"><span style={{ width: `${t.graduated ? 100 : t.progress ?? 0}%` }} /></div>
        <div className="by"><span>{ago(t.ts)}</span><span>by {short(t.creator)}</span></div>
      </div>
    </a>
  )
}

export default function ExploreView() {
  const [target, setTarget] = useState(PAGE)
  const { tokens, status } = useIgnioTokens(target)
  const usd = useEthUsd()
  const [q, setQ] = useState('')
  const [filter, setFilter] = useState<Filter>('All')

  const list = useMemo(() => {
    const s = q.trim().toLowerCase()
    let out = tokens.filter((t) => !s || t.name.toLowerCase().includes(s) || t.symbol.toLowerCase().includes(s) || t.token.toLowerCase().includes(s))
    if (filter === 'Top market cap') out = [...out].sort((a, b) => (b.marketCapEth ?? -1) - (a.marketCapEth ?? -1))
    if (filter === 'Near graduation') out = [...out].filter((t) => !t.graduated).sort((a, b) => (b.progress ?? -1) - (a.progress ?? -1))
    if (filter === 'Newest' || filter === 'All') out = [...out].sort((a, b) => (a.block < b.block ? 1 : -1))
    return out
  }, [tokens, q, filter])

  const top = useMemo(() => tokens.filter((t) => t.marketCapEth !== null).sort((a, b) => (b.marketCapEth ?? 0) - (a.marketCapEth ?? 0))[0], [tokens])
  const loading = status === 'loading'

  return (
    <>
      <div className="x-ex-head">
        <h1 className="x-h1">Explore<br />tokens.</h1>
        <p>Every token launched with Ignio, in one place. Search, filter and jump into any launch.</p>
      </div>

      <div className="x-search">
        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="M20 20l-4-4" /></svg>
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search by name, ticker or address" aria-label="Search tokens" />
        <span className="count">{tokens.length} {tokens.length === 1 ? 'token' : 'tokens'}</span>
      </div>

      <div className="x-chips">
        {FILTERS.map((f) => (
          <button key={f} type="button" className={`x-chip${filter === f ? ' on' : ''}`} onClick={() => setFilter(f)}>{f}</button>
        ))}
      </div>

      <div className={`x-feat${top ? '' : ' x-feat-solo'}`}>
        {top && (
          <a className="x-feat-top" href={`https://robinhoodchain.blockscout.com/token/${top.token}`} target="_blank" rel="noreferrer">
            <Tile t={top} i={0} />
            <div>
              <span className="x-tag" style={{ background: 'rgba(9,9,9,.12)' }}>Top market cap</span>
              <h2>{top.name}<br />{top.symbol}</h2>
              {top.description && <p>{top.description.length > 90 ? top.description.slice(0, 90) + '…' : top.description}</p>}
              <div className="stats">
                <div><small>Market cap</small><strong>{money(top.marketCapEth, usd)}</strong></div>
                <div><small>Curve</small><strong>{top.graduated ? 'Graduated' : top.progress === null ? '—' : `${top.progress.toFixed(0)}%`}</strong></div>
              </div>
            </div>
          </a>
        )}
        <div className="x-feat-cta">
          <div className="x-wave" aria-hidden="true">
            {WAVE.map((h, n) => <i key={n} style={{ height: h, animationDelay: `${n * 70}ms` }} />)}
          </div>
          <h2>Say it.<br />Launch it.</h2>
          <Link href="/launch" className="x-btn">Launch a token</Link>
        </div>
      </div>

      {list.length > 0 && (
        <div className="x-grid">
          {list.map((t, i) => <TokenCard key={t.token} t={t} i={i} usd={usd} />)}
        </div>
      )}

      {loading && (
        <div className="x-grid" aria-label="Loading tokens">
          {Array.from({ length: list.length ? 4 : 8 }, (_, i) => (
            <div key={i} className="x-tk x-skel"><div className="x-tile"><b>&nbsp;</b></div><div className="line" /><div className="line" style={{ width: '60%' }} /></div>
          ))}
        </div>
      )}

      {!loading && list.length === 0 && (
        <div className="x-empty">
          <h3>{status === 'error' ? 'Could not load tokens' : tokens.length ? 'No matches' : 'No Ignio tokens found yet'}</h3>
          <p>{status === 'error' ? 'The Robinhood Chain RPC did not respond. Try again in a moment.' : tokens.length ? 'Try a different search or filter.' : 'Be the first to launch one.'}</p>
          {status === 'error'
            ? <button type="button" className="x-btn dark" onClick={() => setTarget((n) => n + 1)}>Try again</button>
            : <Link href="/launch" className="x-btn dark">Launch a token</Link>}
        </div>
      )}

      {status === 'ready' && (
        <div className="x-more">
          <button type="button" className="x-btn dark" onClick={() => setTarget((n) => n + PAGE)}>
            {tokens.length >= target ? 'Load more' : 'Keep searching older blocks'}
          </button>
        </div>
      )}
    </>
  )
}
IGNIO_EOF
cat > 'components/launch/launch-studio.tsx' <<'IGNIO_EOF'
'use client'

import { useEffect, useRef, useState } from 'react'
import { useAccount, useReadContract } from 'wagmi'
import { formatEther, parseAbi } from 'viem'
import { LaunchForm } from '@/components/launch-page/launch-form'
import { TokenPreview } from '@/components/launch-page/token-preview'
import { isImpersonation } from '@/lib/brand-guard'
import { PONS_V2_FACTORY_ADDRESS } from '@/lib/hooks/use-launch-token'
import { EMPTY_DRAFT, GREETING, understand, type Draft, type Msg } from '@/lib/voice-chat'
import { useVoice } from '@/lib/use-voice'
import { robinhoodChain } from '@/lib/wagmi-config'

type Mode = 'voice' | 'normal'
type Snap = { image: string; name: string; symbol: string; description: string; xLink: string; telegram: string; website: string; fee: string }

const WAVE = [14, 28, 40, 26, 48, 22, 40, 16, 34, 12, 22, 10]
const FEE_ABI = parseAbi(['function launchFee() view returns (uint256)'])
const emptySnap = (d: Draft): Snap => ({ image: '', name: d.tokenName, symbol: d.tokenSymbol, description: d.description, xLink: d.xLink, telegram: d.telegram, website: d.website, fee: d.creatorTaxPct })

const MicIcon = () => (
  <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="9" y="3" width="6" height="11" rx="3" /><path d="M5 11a7 7 0 0 0 14 0M12 18v3" /></svg>
)
const DocIcon = () => (
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h8l5 5v13H6z" /><path d="M14 3v5h5M9 13h7M9 17h7" /></svg>
)
const CheckIcon = () => (
  <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="12" /><path d="M7 12.5l3.2 3.2L17 9" /></svg>
)

export default function LaunchStudio() {
  const { isConnected } = useAccount()
  const [mounted, setMounted] = useState(false)
  const [mode, setModeState] = useState<Mode>('normal')
  const [ready, setReady] = useState(false)
  const [draft, setDraft] = useState<Draft>(EMPTY_DRAFT)
  const [formKey, setFormKey] = useState(0)
  const [snap, setSnap] = useState<Snap>(emptySnap(EMPTY_DRAFT))
  const [msgs, setMsgs] = useState<Msg[]>([{ role: 'ai', text: GREETING }])
  const [input, setInput] = useState('')
  const [interim, setInterim] = useState('')
  const latest = useRef<Draft>(EMPTY_DRAFT) // what the form currently holds, so voice edits build on it
  const msgsRef = useRef<HTMLDivElement>(null)

  const { data: fee } = useReadContract({ address: PONS_V2_FACTORY_ADDRESS, abi: FEE_ABI, functionName: 'launchFee', chainId: robinhoodChain.id })

  // Read mode and any values handed over from the home page (/launch?name=…&symbol=…&description=…)
  useEffect(() => {
    setMounted(true)
    const q = new URLSearchParams(window.location.search)
    const d: Draft = {
      ...EMPTY_DRAFT,
      tokenName: (q.get('name') || '').slice(0, 32),
      tokenSymbol: (q.get('symbol') || '').toUpperCase().slice(0, 10),
      description: (q.get('description') || '').slice(0, 500),
    }
    latest.current = d
    setDraft(d)
    setSnap(emptySnap(d))
    if (q.get('mode') === 'voice') setModeState('voice')
    setReady(true)
  }, [])

  useEffect(() => {
    msgsRef.current?.scrollTo({ top: msgsRef.current.scrollHeight })
  }, [msgs, interim])

  function setMode(m: Mode) {
    setModeState(m)
    window.history.replaceState(null, '', m === 'voice' ? '/launch?mode=voice' : '/launch')
  }

  function send(text: string) {
    const t = text.trim()
    if (!t) return
    const r = understand(t, latest.current)
    setMsgs((m) => [...m, { role: 'me', text: t }, { role: 'ai', text: r.reply }])
    if (JSON.stringify(r.draft) !== JSON.stringify(latest.current)) {
      latest.current = r.draft
      setDraft(r.draft)
      setFormKey((k) => k + 1) // reload the form with the new values
      setSnap(emptySnap(r.draft))
    }
    if (r.review) setMode('normal')
  }

  const voice = useVoice((text, isFinal) => {
    if (isFinal) {
      setInterim('')
      send(text)
    } else {
      setInterim(text)
    }
  })

  const checks: [string, boolean][] = [
    ['Name allowed', snap.name.trim() !== '' && !isImpersonation(snap.name, snap.symbol)],
    ['Ticker set', snap.symbol.trim() !== ''],
    ['Image added', snap.image !== ''],
    ['Wallet connected', mounted && isConnected],
  ]
  const feeText = fee === undefined ? '…' : `${Number(formatEther(fee)).toLocaleString(undefined, { maximumFractionDigits: 6 })} ETH`

  return (
    <>
      <div className="x-l-head">
        <h1 className="x-h1">Launch.</h1>
        <div className="x-toggle" role="group" aria-label="Launch mode">
          <button type="button" className={mode === 'voice' ? 'on' : ''} aria-pressed={mode === 'voice'} onClick={() => setMode('voice')}><MicIcon /> Voice mode</button>
          <button type="button" className={mode === 'normal' ? 'on' : ''} aria-pressed={mode === 'normal'} onClick={() => setMode('normal')}><DocIcon /> Normal mode</button>
        </div>
      </div>

      <div className="x-l-grid">
        <div className="x-stack">
          {/* Normal mode: the existing launch form. It stays mounted while hidden so nothing typed is lost. */}
          <div hidden={mode !== 'normal'}>
            {ready && (
              <LaunchForm
                key={formKey}
                initial={draft}
                onChange={(d) => {
                  latest.current = {
                    tokenName: d.tokenName, tokenSymbol: d.tokenSymbol, description: d.description,
                    xLink: d.xLink, telegram: d.telegram, website: d.website, creatorTaxPct: d.creatorTaxPct ?? '0',
                  }
                  setSnap({ image: d.tokenImagePreview || '', name: d.tokenName, symbol: d.tokenSymbol, description: d.description, xLink: d.xLink, telegram: d.telegram, website: d.website, fee: d.creatorTaxPct ?? '0' })
                }}
              />
            )}
          </div>

          {mode === 'voice' && (
            <div className="x-convo">
              <div className="top">
                <span className={`x-live${voice.listening ? '' : ' idle'}`}>{voice.listening ? 'Listening…' : 'Tap the mic to talk'}</span>
                <span className="x-tag" style={{ background: 'rgba(255,255,255,.1)', color: '#bbb' }}>Voice mode</span>
              </div>
              <div className="x-msgs" ref={msgsRef} aria-live="polite">
                {msgs.map((m, i) => <p key={i} className={m.role}>{m.text}</p>)}
                {interim && <p className="me ghost">{interim}…</p>}
              </div>
              <form
                className="x-dock"
                onSubmit={(e) => {
                  e.preventDefault()
                  send(input)
                  setInput('')
                }}
              >
                <div className={`x-wave${voice.listening ? ' on' : ''}`} aria-hidden="true">
                  {WAVE.map((h, n) => <i key={n} style={{ height: h, animationDelay: `${n * 70}ms` }} />)}
                </div>
                <input value={input} onChange={(e) => setInput(e.target.value)} placeholder="Or type your message…" aria-label="Type your message" />
                <button type="button" className={`x-mic${voice.listening ? ' on' : ''}`} onClick={voice.toggle} aria-pressed={voice.listening} aria-label={voice.listening ? 'Stop listening' : 'Start voice input'}>
                  <MicIcon />
                </button>
              </form>
              {voice.error && <p className="x-err" role="alert">{voice.error}</p>}
            </div>
          )}
        </div>

        <div className="x-stack x-sticky">
          <div>
            <div className="x-pv-label">LIVE PREVIEW</div>
            <TokenPreview
              image={snap.image || undefined}
              name={snap.name}
              symbol={snap.symbol}
              description={snap.description}
              xLink={snap.xLink}
              telegram={snap.telegram}
              website={snap.website}
            />
          </div>
          <div className="x-chk">
            <h3>Safety checks</h3>
            <ul>
              {checks.map(([label, ok]) => (
                <li key={label} className={ok ? '' : 'off'}><CheckIcon />{label}</li>
              ))}
            </ul>
          </div>
          {mode === 'voice' && (
            <button type="button" className="x-btn big" onClick={() => { send('review') }}>Review &amp; deploy</button>
          )}
          <p className="x-fine">Launch fee {feeText} · Creator fee {snap.fee || '0'}% · Your wallet signs the transaction</p>
        </div>
      </div>
    </>
  )
}
IGNIO_EOF
cat > 'components/ConnectWallet.tsx' <<'IGNIO_EOF'
'use client'

import { useAccount, useConnect, useSwitchChain, useDisconnect } from 'wagmi'
import { Button } from '@/components/ui/button'
import { robinhoodChain } from '@/lib/wagmi-config'

export default function ConnectWallet() {
  const { address, isConnected, chain } = useAccount()
  const { connect, connectors, isPending } = useConnect()
  const { switchChain, isPending: isSwitching } = useSwitchChain()
  const { disconnect } = useDisconnect()

  if (isConnected) {
    return (
      <div className="x-wbtns">
        <p className="x-wconn">
          Connected: <code>{address?.slice(0, 6)}…{address?.slice(-4)}</code>
        </p>
        {chain?.id !== robinhoodChain.id && (
          <Button onClick={() => switchChain({ chainId: robinhoodChain.id })} disabled={isSwitching} className="w-full obrix-button">
            {isSwitching ? 'Switching network…' : 'Switch to Robinhood Chain'}
          </Button>
        )}
        <button type="button" className="alt" onClick={() => disconnect()}>
          Disconnect wallet
        </button>
      </div>
    )
  }

  return (
    <div className="x-wbtns">
      {connectors.map((connector, i) => (
        <button
          key={connector.uid}
          type="button"
          className={i === 0 ? '' : 'alt'}
          onClick={() => connect({ connector })}
          disabled={isPending}
        >
          {isPending ? 'Connecting…' : `Connect ${connector.name}`}
        </button>
      ))}
    </div>
  )
}
IGNIO_EOF
cat > 'components/landing/landing.tsx' <<'IGNIO_EOF'
'use client'

import { useRouter } from 'next/navigation'
import { useMemo, useRef, useState } from 'react'
import SiteNav from '@/components/site/site-nav'
import { isImpersonation, RESERVED_MESSAGE } from '@/lib/brand-guard'
import { EXAMPLE_PROMPT, launchHref, parsePrompt } from '@/lib/parse-prompt'
import { useVoice } from '@/lib/use-voice'
import './landing.css'

const WAVE = [14, 28, 40, 26, 48, 22, 40, 16, 34, 12, 22, 10]
const PILLS: [string, string][] = [
  ['Fan token', 'Create a fan token called '],
  ['Rewards', 'Create a rewards token called '],
  ['Membership', 'Create a membership token called '],
  ['Chat instead', ''],
]

export default function Landing() {
  const router = useRouter()
  const [prompt, setPrompt] = useState('')
  const [error, setError] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)

  function go(text: string) {
    const p = parsePrompt(text)
    if (isImpersonation(p.name, p.symbol)) {
      setError(RESERVED_MESSAGE)
      return
    }
    setError('')
    router.push(launchHref(p))
  }

  const voice = useVoice((text, isFinal) => {
    setPrompt(text)
    if (isFinal && /\blaunch\b/i.test(text) && parsePrompt(text).name) go(text)
  })

  const parsed = useMemo(() => parsePrompt(prompt || EXAMPLE_PROMPT), [prompt])
  const bubble = parsed.name
    ? `${parsed.name} (${parsed.symbol}) is ready to configure.`
    : 'Tell me what to create and I will fill in the launch form.'

  function pick(text: string) {
    setError('')
    voice.clearError()
    setPrompt(text)
    inputRef.current?.focus()
  }

  return (
    <div className="ig">
      <section className="ig-hero">
        <SiteNav tone="lime" />

        <div className="ig-stage">
          <p className="ig-sub">Create a token with your voice or in chat. No forms, no code.</p>
          <h1 className="ig-h1">
            <span>Say it.</span>
            <span>Launch it.</span>
          </h1>
          <div className="ig-bubble" aria-live="polite">
            {bubble}
            <small>Say “launch” to continue</small>
          </div>
          <button type="button" className="ig-launch" onClick={() => go(prompt || EXAMPLE_PROMPT)}>
            Launch it
          </button>
        </div>

        <div className="ig-pills">
          {PILLS.map(([label, text]) => (
            <button key={label} type="button" className="ig-pill" onClick={() => pick(text)}>
              {label}
            </button>
          ))}
        </div>

        <form
          className="ig-bar"
          onSubmit={(e) => {
            e.preventDefault()
            go(prompt || EXAMPLE_PROMPT)
          }}
        >
          <div className={`ig-wave${voice.listening ? ' on' : ''}`} aria-hidden="true">
            {WAVE.map((h, n) => (
              <i key={n} style={{ height: h, animationDelay: `${n * 70}ms` }} />
            ))}
          </div>
          <div className="ig-field">
            {!prompt && (
              <div className="ig-ghost" aria-hidden="true">
                Create a rewards token called Spark<em>, ten million supply</em>
              </div>
            )}
            <input
              ref={inputRef}
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              aria-label="Describe the token you want to create"
              autoComplete="off"
              spellCheck={false}
            />
          </div>
          <button
            type="button"
            className={`ig-mic${voice.listening ? ' on' : ''}`}
            onClick={voice.toggle}
            aria-pressed={voice.listening}
            aria-label={voice.listening ? 'Stop listening' : 'Start voice input'}
          >
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <rect x="9" y="3" width="6" height="11" rx="3" />
              <path d="M5 11a7 7 0 0 0 14 0M12 18v3" />
            </svg>
          </button>
        </form>
        {(error || voice.error) && <p className="ig-error" role="alert">{error || voice.error}</p>}
      </section>
    </div>
  )
}
IGNIO_EOF
cat > 'app/explore/page.tsx' <<'IGNIO_EOF'
import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'
import ExploreView from '@/components/explore/explore-view'

export const metadata: Metadata = { title: 'Explore – Ignio', description: 'Browse tokens launched with Ignio.' }

export default function ExplorePage() {
  return (
    <PageShell>
      <ExploreView />
    </PageShell>
  )
}
IGNIO_EOF
cat > 'app/launch/page.tsx' <<'IGNIO_EOF'
import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'
import LaunchStudio from '@/components/launch/launch-studio'

export const metadata: Metadata = { title: 'Launch – Ignio', description: 'Launch a token by voice or with the form.' }

export default function LaunchPage() {
  return (
    <PageShell>
      <LaunchStudio />
    </PageShell>
  )
}
IGNIO_EOF
cat > 'app/how-it-works/page.tsx' <<'IGNIO_EOF'
import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'

export const metadata: Metadata = { title: 'How It Works – Ignio' }

export default function HowItWorksPage() {
  return <PageShell blank />
}
IGNIO_EOF
cat > 'app/docs/page.tsx' <<'IGNIO_EOF'
import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'

export const metadata: Metadata = { title: 'Docs – Ignio' }

export default function DocsPage() {
  return <PageShell blank />
}
IGNIO_EOF
cat > 'app/about/page.tsx' <<'IGNIO_EOF'
import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'

export const metadata: Metadata = { title: 'About – Ignio' }

export default function AboutPage() {
  return <PageShell blank />
}
IGNIO_EOF
python3 - <<'IGNIO_PY'
import sys
p = 'components/launch-page/launch-form.tsx'
s = open(p).read()
if 'id="launch-form"' in s:
    print('launch-form.tsx already patched, skipping'); sys.exit(0)

old_iface = "  initial?: { tokenName?: string; tokenSymbol?: string; description?: string }"
new_iface = "  initial?: { tokenName?: string; tokenSymbol?: string; description?: string; xLink?: string; telegram?: string; website?: string; creatorTaxPct?: string }"
old_state = "    xLink: '',\n    telegram: '',\n    website: '',\n    feeReceiver: address || '',\n    creatorTaxPct: '0',"
new_state = "    xLink: initial?.xLink ?? '',\n    telegram: initial?.telegram ?? '',\n    website: initial?.website ?? '',\n    feeReceiver: address || '',\n    creatorTaxPct: initial?.creatorTaxPct ?? '0',"
start = "  return (\n    <Card className=\"obrix-launch-card"
for needle in (old_iface, old_state, start):
    if needle not in s:
        sys.exit('launch-form.tsx is not in the expected shape; nothing changed. Missing: ' + needle[:60])

s = s.replace(old_iface, new_iface).replace(old_state, new_state)
head = s[:s.index(start)].replace("import { Card } from '@/components/ui/card'\n", "")
markup = r'''  return (
    <form id="launch-form" onSubmit={handleSubmit} className="x-lform">
      {/* Token Image */}
      <section className="x-fsec x-fs-image">
        <h3>Token image</h3>
        <p className="sub">Shown on Explore and on your token page.</p>
        <ImageUploader
          onImageSelect={handleImageSelect}
          preview={formState.tokenImagePreview || undefined}
        />
        {uploadStatus && <p className="upl">{uploadStatus}</p>}
      </section>

      {/* Name, symbol, description */}
      <section className="x-fsec x-fs-details">
        <h3>Details</h3>
        <p className="sub">Name it, give it a ticker, tell people why it matters.</p>
        <div className="two">
          <div className="field">
            <Label htmlFor="tokenName">Token Name</Label>
            <Input id="tokenName" placeholder="Enter token name" value={formState.tokenName} onChange={handleInputChange('tokenName')} />
          </div>
          <div className="field">
            <Label htmlFor="tokenSymbol">Token Symbol</Label>
            <Input id="tokenSymbol" placeholder="TICKER" value={formState.tokenSymbol} onChange={handleSymbolChange} maxLength={10} className="uppercase" />
          </div>
        </div>
        <div className="field">
          <Label htmlFor="description">Description</Label>
          <Textarea id="description" placeholder="What makes your token special?" value={formState.description} onChange={handleDescriptionChange} rows={4} />
        </div>
      </section>

      {/* X, Telegram, Website */}
      <section className="x-fsec x-fs-links">
        <h3>Links</h3>
        <p className="sub">Help holders find you.</p>
        <div className="field">
          <Label htmlFor="xLink">X Link</Label>
          <Input id="xLink" type="url" placeholder="x.com/username" value={formState.xLink} onChange={handleInputChange('xLink')} />
        </div>
        <div className="two">
          <div className="field">
            <Label htmlFor="telegram">Telegram (optional)</Label>
            <Input id="telegram" placeholder="t.me/groupname" value={formState.telegram} onChange={handleInputChange('telegram')} />
          </div>
          <div className="field">
            <Label htmlFor="website">Website (optional)</Label>
            <Input id="website" type="url" placeholder="https://yoursite.com" value={formState.website} onChange={handleInputChange('website')} />
          </div>
        </div>
      </section>

      {/* Creator fee + fee receiver */}
      <section className="x-fsec x-fs-fee">
        <h3>Creator fee</h3>
        <p className="sub">Paid on every buy and sell. Fixed at launch.</p>
        <div className="field">
          <Label htmlFor="creatorTax">Creator fee on every trade (%)</Label>
          <div className="obrix-x-chips">
            {['0', '0.5', '1', '2'].map((v) => (
              <button key={v} type="button" className={(formState.creatorTaxPct ?? '0') === v ? 'is-on' : ''} onClick={() => { const ns = { ...formState, creatorTaxPct: v }; setFormState(ns); onChange?.(ns) }}>{v}%</button>
            ))}
          </div>
          <Input id="creatorTax" type="text" inputMode="decimal" placeholder="0" value={formState.creatorTaxPct ?? '0'} onChange={(e) => { const ns = { ...formState, creatorTaxPct: e.currentTarget.value.replace(/[^0-9.]/g, '') }; setFormState(ns); onChange?.(ns) }} />
          <p className="text-xs text-zinc-500">Paid to the Fee Receiver on every buy and sell. Fixed at launch, it cannot be changed later.{maxTaxPct !== null ? ` Maximum allowed: ${maxTaxPct}%.` : ''} Pons also charges its own standard trading fee.</p>
        </div>
        <div className="field">
          <Label htmlFor="feeReceiver">Fee Receiver</Label>
          <Input
            id="feeReceiver"
            placeholder="0x..."
            value={formState.feeReceiver || address || ''}
            onChange={handleInputChange('feeReceiver')}
          />
          <p className="text-xs text-muted-foreground">Wallet address to receive fees (defaults to connected wallet)</p>
        </div>
      </section>

      {/* Submit Area */}
      <div className="x-fs-submit">
        {!isConnected ? (
          <ConnectWallet />
        ) : chainId !== robinhoodChain.id ? (
          <Button type="button" onClick={() => switchChain({ chainId: robinhoodChain.id })} disabled={isSwitching} className="w-full obrix-button py-6 text-base">
            {isSwitching ? 'Switching network…' : 'Switch to Robinhood Chain'}
          </Button>
        ) : (
          <Button
            type="submit"
            disabled={isLoading}
            className="w-full obrix-button text-background font-semibold py-6 text-base disabled:opacity-50"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Launching...
              </>
            ) : (
              'Deploy on Pons V2'
            )}
          </Button>
        )}

        {submitMessage && <div className="x-note">{submitMessage}</div>}
        <TransactionStatus status={isLoading || isConfirming ? 'loading' : isConfirmed ? 'success' : error || receiptError ? 'error' : 'idle'} txHash={txHash || undefined} message={error || (receiptError instanceof Error ? receiptError.message : undefined)} />
      </div>
    </form>
  )
}
'''
open(p, 'w').write(head + markup)
print('launch-form.tsx patched (logic unchanged, markup restyled)')
IGNIO_PY
rm -f components/launch-page/launch-hub.tsx components/launch-page/launch-hub.css components/landing/logo.tsx
echo "Done. Run: pnpm dev"
