import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'

export const metadata: Metadata = { title: 'Docs – Ignio' }

export default function DocsPage() {
  return <PageShell blank />
}
