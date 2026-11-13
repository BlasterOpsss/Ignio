import type { Metadata } from 'next'
import PageShell from '@/components/site/page-shell'

export const metadata: Metadata = { title: 'About – Ignio' }

export default function AboutPage() {
  return <PageShell blank />
}
