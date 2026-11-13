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
