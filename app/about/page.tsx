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
