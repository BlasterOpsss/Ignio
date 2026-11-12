import type { Metadata, Viewport } from 'next'
import { RainbowKitProviderWrapper } from '@/components/providers/rainbow-kit-provider'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'], variable: '--font-inter', display: 'swap' })

export const metadata: Metadata = {
  title: 'Ignio – Say it. Launch it.',
  description: 'Create a token with your voice or in chat. Deploy through the Pons V2 factory on Robinhood Chain.',
}

export const viewport: Viewport = {
  colorScheme: 'dark',
  themeColor: '#090909',
}

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={`${inter.variable} antialiased`}>
        <RainbowKitProviderWrapper>{children}</RainbowKitProviderWrapper>
      </body>
    </html>
  )
}
