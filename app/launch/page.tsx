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
