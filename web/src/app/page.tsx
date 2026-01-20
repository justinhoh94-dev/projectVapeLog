'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { Leaf, Sparkles, TrendingUp } from 'lucide-react';
import { getSessionCount } from '@/lib/db';

export default function Home() {
  const [sessionCount, setSessionCount] = useState(0);

  useEffect(() => {
    getSessionCount().then(setSessionCount);
  }, []);

  return (
    <main className="min-h-screen bg-vape-gradient">
      <div className="container mx-auto px-6 py-10 max-w-2xl">
        {/* Header */}
        <header className="mb-8">
          <h1 className="text-3xl font-bold text-white mb-2 text-shadow">
            VapeLog
          </h1>
          <p className="text-white/80 text-sm">
            {sessionCount} sessions logged
          </p>
        </header>

        {/* Hero Card */}
        <div className="glass-card p-6 mb-8">
          <p className="text-sm text-white/90 mb-3">Welcome back</p>
          <h2 className="text-2xl font-bold text-white mb-4 leading-tight">
            Discover your ideal terpene and cannabinoid profile
          </h2>
          <p className="text-sm text-white/90 leading-relaxed">
            Track each session, learn about terpene effects, and review how
            different strains support your desired mood and relief goals.
          </p>
        </div>

        {/* Action Buttons */}
        <div className="space-y-5">
          <ActionButton
            href="/log-session"
            icon={<Leaf className="w-6 h-6" />}
            title="Log a Session"
            subtitle="Record the strain, dose, and how it made you feel."
          />

          <ActionButton
            href="/terpenes"
            icon={<Sparkles className="w-6 h-6" />}
            title="Terpene Explorer"
            subtitle="Browse terpene profiles and learn their effects."
          />

          <ActionButton
            href="/insights"
            icon={<TrendingUp className="w-6 h-6" />}
            title="Insights & Trends"
            subtitle="Review patterns in your usage and wellness goals."
          />
        </div>

        {/* Install Prompt for PWA */}
        <div className="mt-12 text-center">
          <p className="text-xs text-white/60">
            💡 Add to home screen for quick access
          </p>
        </div>
      </div>
    </main>
  );
}

interface ActionButtonProps {
  href: string;
  icon: React.ReactNode;
  title: string;
  subtitle: string;
}

function ActionButton({ href, icon, title, subtitle }: ActionButtonProps) {
  return (
    <Link href={href} className="block">
      <button className="w-full glass-button p-5 text-left">
        <div className="flex items-center gap-4">
          {/* Icon */}
          <div className="flex-shrink-0 w-14 h-14 rounded-full bg-white/18 flex items-center justify-center text-white">
            {icon}
          </div>

          {/* Text */}
          <div className="flex-1 min-w-0">
            <h3 className="text-lg font-semibold text-white mb-1">
              {title}
            </h3>
            <p className="text-sm text-white/85 leading-snug">
              {subtitle}
            </p>
          </div>

          {/* Chevron */}
          <div className="flex-shrink-0 text-white/70">
            <svg
              className="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M9 5l7 7-7 7"
              />
            </svg>
          </div>
        </div>
      </button>
    </Link>
  );
}
