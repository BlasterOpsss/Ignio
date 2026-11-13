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
