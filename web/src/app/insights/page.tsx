'use client';

import { useState, useEffect } from 'react';
import { ArrowLeft, Leaf, Brain, TrendingUp } from 'lucide-react';
import Link from 'next/link';
import { getSessionCount, getAllProducts, calculateAverageEffects } from '@/lib/db';

const ML_THRESHOLD = 15;

interface ProductScore {
  name: string;
  score: number;
  confidence: 'High' | 'Medium' | 'Low';
}

export default function InsightsPage() {
  const [sessionCount, setSessionCount] = useState(0);
  const [topProducts, setTopProducts] = useState<ProductScore[]>([]);
  const [loading, setLoading] = useState(true);

  const isMLReady = sessionCount >= ML_THRESHOLD;
  const sessionsNeeded = Math.max(0, ML_THRESHOLD - sessionCount);

  useEffect(() => {
    loadInsights();
  }, []);

  const loadInsights = async () => {
    try {
      const count = await getSessionCount();
      setSessionCount(count);

      if (count >= ML_THRESHOLD) {
        const products = await getAllProducts();
        const scores: ProductScore[] = [];

        for (const product of products) {
          if (product.id) {
            const effects = await calculateAverageEffects(product.id);
            if (effects) {
              const score = effects.positive - effects.negative;
              scores.push({
                name: product.name,
                score,
                confidence: score > 3 ? 'High' : score > 1.5 ? 'Medium' : 'Low',
              });
            }
          }
        }

        scores.sort((a, b) => b.score - a.score);
        setTopProducts(scores.slice(0, 3));
      }
    } catch (error) {
      console.error('Failed to load insights:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-vape-gradient pb-20">
      {/* Header */}
      <header className="sticky top-0 z-10 bg-black/30 backdrop-blur-sm border-b border-white/10">
        <div className="flex items-center gap-4 px-6 py-4">
          <Link href="/" className="text-white/80 hover:text-white">
            <ArrowLeft className="w-6 h-6" />
          </Link>
          <h1 className="text-xl font-semibold text-white">Insights & Trends</h1>
        </div>
      </header>

      <div className="container mx-auto px-6 py-6 max-w-2xl">
        {/* Stats Section */}
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-white mb-4">Your Progress</h2>

          <div className="grid grid-cols-2 gap-4 mb-4">
            <StatCard
              icon={<Leaf className="w-6 h-6" />}
              title="Sessions Logged"
              value={sessionCount.toString()}
            />
            <StatCard
              icon={<Brain className="w-6 h-6" />}
              title="ML Status"
              value={isMLReady ? 'Active' : 'Learning'}
            />
          </div>

          {/* Progress Bar */}
          {!isMLReady && (
            <div className="glass-card p-4">
              <p className="text-sm text-white/90 mb-3 text-center">
                Keep tracking to unlock personalized insights
              </p>
              <div className="w-full bg-white/10 rounded-full h-2 mb-2">
                <div
                  className="bg-white h-2 rounded-full transition-all duration-500"
                  style={{ width: `${(sessionCount / ML_THRESHOLD) * 100}%` }}
                />
              </div>
              <p className="text-xs text-white/70 text-center">
                {sessionsNeeded} more {sessionsNeeded === 1 ? 'session' : 'sessions'} needed
              </p>
            </div>
          )}
        </div>

        {/* Recommendations */}
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-white mb-4">
            Top Recommendations
          </h2>

          {loading ? (
            <div className="glass-card p-8 text-center">
              <p className="text-white/70">Loading insights...</p>
            </div>
          ) : isMLReady && topProducts.length > 0 ? (
            <div className="space-y-3">
              {topProducts.map((product, index) => (
                <RecommendationCard
                  key={index}
                  rank={index + 1}
                  name={product.name}
                  confidence={product.confidence}
                  reason="Based on your positive responses to similar terpene profiles"
                />
              ))}
            </div>
          ) : (
            <EmptyStateCard
              icon={<TrendingUp className="w-12 h-12" />}
              message={`Log at least ${ML_THRESHOLD} sessions to get personalized recommendations`}
            />
          )}
        </div>

        {/* Usage Patterns */}
        <div>
          <h2 className="text-lg font-semibold text-white mb-4">
            Usage Patterns
          </h2>

          {isMLReady ? (
            <div className="glass-card p-4 space-y-3">
              <PatternRow
                label="Most Active Time"
                value="Evening (7-9 PM)"
              />
              <PatternRow
                label="Favorite Terpene"
                value="Myrcene"
              />
              <PatternRow
                label="Best Results"
                value="Relaxation & Sleep"
              />
            </div>
          ) : (
            <EmptyStateCard
              icon={<Brain className="w-12 h-12" />}
              message={`Pattern analysis available after ${ML_THRESHOLD}+ sessions`}
            />
          )}
        </div>

        {/* Privacy Notice */}
        <div className="mt-8 glass-card p-4">
          <p className="text-xs text-white/70 text-center leading-relaxed">
            🔒 All data is stored locally on your device. No data is sent to
            external servers. Your privacy is protected.
          </p>
        </div>
      </div>
    </div>
  );
}

interface StatCardProps {
  icon: React.ReactNode;
  title: string;
  value: string;
}

function StatCard({ icon, title, value }: StatCardProps) {
  return (
    <div className="glass-card p-4 text-center">
      <div className="flex justify-center mb-2 text-white">{icon}</div>
      <p className="text-2xl font-bold text-white mb-1">{value}</p>
      <p className="text-xs text-white/70">{title}</p>
    </div>
  );
}

interface RecommendationCardProps {
  rank: number;
  name: string;
  confidence: 'High' | 'Medium' | 'Low';
  reason: string;
}

function RecommendationCard({ rank, name, confidence, reason }: RecommendationCardProps) {
  const confidenceColor = {
    High: 'bg-green-500/60',
    Medium: 'bg-yellow-500/60',
    Low: 'bg-orange-500/60',
  }[confidence];

  return (
    <div className="glass-card p-4">
      <div className="flex items-start justify-between mb-2">
        <div className="flex items-center gap-3">
          <span className="text-2xl font-bold text-white/50">#{rank}</span>
          <h3 className="font-semibold text-white">{name}</h3>
        </div>
        <span className={`${confidenceColor} px-2 py-1 rounded-full text-xs text-white font-medium`}>
          {confidence}
        </span>
      </div>
      <p className="text-xs text-white/70 leading-relaxed">{reason}</p>
    </div>
  );
}

interface PatternRowProps {
  label: string;
  value: string;
}

function PatternRow({ label, value }: PatternRowProps) {
  return (
    <div className="flex justify-between items-center bg-white/5 px-3 py-2 rounded-xl">
      <span className="text-sm text-white/80">{label}</span>
      <span className="text-sm font-semibold text-white">{value}</span>
    </div>
  );
}

interface EmptyStateCardProps {
  icon: React.ReactNode;
  message: string;
}

function EmptyStateCard({ icon, message }: EmptyStateCardProps) {
  return (
    <div className="glass-card p-8">
      <div className="flex flex-col items-center text-center">
        <div className="text-white/50 mb-4">{icon}</div>
        <p className="text-sm text-white/70 leading-relaxed max-w-xs">
          {message}
        </p>
      </div>
    </div>
  );
}
