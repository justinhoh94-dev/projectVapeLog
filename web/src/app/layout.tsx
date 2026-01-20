import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'VapeLog - Cannabis Usage Tracker',
  description: 'Privacy-first cannabis tracking with ML-powered label scanning',
  manifest: '/manifest.json',
  themeColor: '#193E33',
  viewport: {
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
    userScalable: false,
  },
  appleWebApp: {
    capable: true,
    statusBarStyle: 'black-translucent',
    title: 'VapeLog',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <link rel="apple-touch-icon" href="/icon-192.png" />
      </head>
      <body className="overflow-x-hidden">
        {children}
      </body>
    </html>
  )
}
