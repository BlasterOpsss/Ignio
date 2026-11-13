import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'
import DocsView from '@/components/docs/docs-view'

export const metadata: Metadata = { title: 'Docs – Ignio', description: 'Guides, concepts and contract references for Ignio.' }

export default function DocsPage() {
  return (
    <PageShell>
      <DocsView />
    </PageShell>
  )
}
