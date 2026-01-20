'use client';

import { ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { TERPENES } from '@/lib/terpenes';

export default function TerpenesPage() {
  return (
    <div className="min-h-screen bg-vape-gradient pb-20">
      {/* Header */}
      <header className="sticky top-0 z-10 bg-black/30 backdrop-blur-sm border-b border-white/10">
        <div className="flex items-center gap-4 px-6 py-4">
          <Link href="/" className="text-white/80 hover:text-white">
            <ArrowLeft className="w-6 h-6" />
          </Link>
          <h1 className="text-xl font-semibold text-white">Terpene Explorer</h1>
        </div>
      </header>

      <div className="container mx-auto px-6 py-6 max-w-2xl">
        {/* Introduction */}
        <div className="glass-card p-6 mb-6">
          <h2 className="text-xl font-bold text-white mb-3">
            Understanding Terpenes
          </h2>
          <p className="text-sm text-white/90 leading-relaxed">
            Terpenes are aromatic compounds found in cannabis that contribute to
            its scent, flavor, and effects. Each terpene has unique properties
            that can influence your experience.
          </p>
        </div>

        {/* Terpene Cards */}
        <div className="space-y-4">
          {TERPENES.map((terpene) => (
            <div key={terpene.id} className="glass-card p-6">
              {/* Header */}
              <div className="flex items-start gap-4 mb-4">
                <div className="text-4xl">{terpene.icon}</div>
                <div className="flex-1">
                  <h3 className="text-xl font-bold text-white mb-1">
                    {terpene.name}
                  </h3>
                  <p className="text-sm text-white/70 italic">
                    {terpene.aroma}
                  </p>
                </div>
              </div>

              {/* Description */}
              <p className="text-sm text-white/90 mb-4 leading-relaxed">
                {terpene.description}
              </p>

              {/* Effects */}
              <div className="flex flex-wrap gap-2">
                {terpene.effects.map((effect) => (
                  <span
                    key={effect}
                    className="bg-white/15 px-3 py-1 rounded-full text-xs text-white font-medium"
                  >
                    {effect}
                  </span>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Educational Note */}
        <div className="mt-8 glass-card p-4">
          <p className="text-xs text-white/70 text-center leading-relaxed">
            💡 Terpene profiles can help you choose products that match your
            desired effects. Look for lab results that show terpene percentages
            on product labels.
          </p>
        </div>
      </div>
    </div>
  );
}
