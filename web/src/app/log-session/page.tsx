'use client';

import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { ArrowLeft, Camera } from 'lucide-react';
import Link from 'next/link';
import { addProduct, addSession } from '@/lib/db';
import { ScanResult } from '@/lib/scanner';

function LogSessionContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const fromScan = searchParams.get('fromScan') === 'true';

  const [scanData, setScanData] = useState<ScanResult | null>(null);
  const [formData, setFormData] = useState({
    productName: '',
    brand: '',
    type: 'flower',
    route: 'smoke',
    thc: '',
    cbd: '',
    cbg: '',
    doseMg: '',
    notes: '',
  });

  useEffect(() => {
    if (fromScan) {
      const stored = localStorage.getItem('pendingScanResult');
      if (stored) {
        const data: ScanResult = JSON.parse(stored);
        setScanData(data);

        // Pre-fill form with scanned data
        setFormData(prev => ({
          ...prev,
          thc: data.cannabinoids.THC?.toString() || '',
          cbd: data.cannabinoids.CBD?.toString() || '',
          cbg: data.cannabinoids.CBG?.toString() || '',
        }));

        localStorage.removeItem('pendingScanResult');
      }
    }
  }, [fromScan]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    try {
      // Create product
      const productId = await addProduct({
        name: formData.productName || 'Unnamed Product',
        brand: formData.brand || undefined,
        type: formData.type,
        route: formData.route,
        thcPercent: formData.thc ? parseFloat(formData.thc) : undefined,
        cbdPercent: formData.cbd ? parseFloat(formData.cbd) : undefined,
        cbgPercent: formData.cbg ? parseFloat(formData.cbg) : undefined,
        myrcene: scanData?.terpenes.Myrcene,
        limonene: scanData?.terpenes.Limonene,
        pinene: scanData?.terpenes.Pinene,
        caryophyllene: scanData?.terpenes.Caryophyllene,
        humulene: scanData?.terpenes.Humulene,
        linalool: scanData?.terpenes.Linalool,
        terpinolene: scanData?.terpenes.Terpinolene,
        ocimene: scanData?.terpenes.Ocimene,
        notes: formData.notes || undefined,
      });

      // Create session
      await addSession({
        productId: productId,
        dateTime: new Date(),
        doseMg: formData.doseMg ? parseFloat(formData.doseMg) : undefined,
        withCompany: false,
        hadCaffeine: false,
        hadAlcohol: false,
        hadFood: false,
      });

      // Redirect to home
      router.push('/?success=true');
    } catch (error) {
      console.error('Failed to save session:', error);
      alert('Failed to save session. Please try again.');
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
          <h1 className="text-xl font-semibold text-white">Log a Session</h1>
        </div>
      </header>

      <div className="container mx-auto px-6 py-6 max-w-2xl">
        {/* Scanner Button */}
        {!scanData && (
          <Link
            href="/scanner"
            className="block mb-6 glass-button p-4 text-center"
          >
            <div className="flex items-center justify-center gap-3 text-white">
              <Camera className="w-5 h-5" />
              <span className="font-semibold">Use Camera to Scan Label</span>
            </div>
          </Link>
        )}

        {/* Scanned Data Preview */}
        {scanData && (
          <div className="glass-card p-4 mb-6">
            <p className="text-sm text-green-400 mb-2">✓ Data from scan:</p>
            <div className="flex flex-wrap gap-2 text-xs">
              {Object.entries(scanData.cannabinoids).map(([name, value]) => (
                <span key={name} className="bg-white/20 px-2 py-1 rounded text-white">
                  {name}: {value}%
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Product Name */}
          <div>
            <label className="block text-sm text-white/90 mb-2">
              Product Name *
            </label>
            <input
              type="text"
              required
              value={formData.productName}
              onChange={e => setFormData({ ...formData, productName: e.target.value })}
              className="w-full glass-card px-4 py-3 text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/30"
              placeholder="e.g., Blue Dream"
            />
          </div>

          {/* Brand */}
          <div>
            <label className="block text-sm text-white/90 mb-2">Brand</label>
            <input
              type="text"
              value={formData.brand}
              onChange={e => setFormData({ ...formData, brand: e.target.value })}
              className="w-full glass-card px-4 py-3 text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/30"
              placeholder="e.g., Stiiizy"
            />
          </div>

          {/* Type & Route */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-white/90 mb-2">Type</label>
              <select
                value={formData.type}
                onChange={e => setFormData({ ...formData, type: e.target.value })}
                className="w-full glass-card px-4 py-3 text-white focus:outline-none focus:ring-2 focus:ring-white/30"
              >
                <option value="flower">Flower</option>
                <option value="concentrate">Concentrate</option>
                <option value="edible">Edible</option>
                <option value="vape">Vape</option>
              </select>
            </div>

            <div>
              <label className="block text-sm text-white/90 mb-2">Route</label>
              <select
                value={formData.route}
                onChange={e => setFormData({ ...formData, route: e.target.value })}
                className="w-full glass-card px-4 py-3 text-white focus:outline-none focus:ring-2 focus:ring-white/30"
              >
                <option value="smoke">Smoke</option>
                <option value="vape">Vape</option>
                <option value="edible">Edible</option>
                <option value="topical">Topical</option>
              </select>
            </div>
          </div>

          {/* Cannabinoids */}
          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm text-white/90 mb-2">THC %</label>
              <input
                type="number"
                step="0.1"
                value={formData.thc}
                onChange={e => setFormData({ ...formData, thc: e.target.value })}
                className="w-full glass-card px-4 py-3 text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/30"
                placeholder="23.5"
              />
            </div>
            <div>
              <label className="block text-sm text-white/90 mb-2">CBD %</label>
              <input
                type="number"
                step="0.1"
                value={formData.cbd}
                onChange={e => setFormData({ ...formData, cbd: e.target.value })}
                className="w-full glass-card px-4 py-3 text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/30"
                placeholder="0.8"
              />
            </div>
            <div>
              <label className="block text-sm text-white/90 mb-2">CBG %</label>
              <input
                type="number"
                step="0.1"
                value={formData.cbg}
                onChange={e => setFormData({ ...formData, cbg: e.target.value })}
                className="w-full glass-card px-4 py-3 text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/30"
                placeholder="1.2"
              />
            </div>
          </div>

          {/* Dose */}
          <div>
            <label className="block text-sm text-white/90 mb-2">Dose (mg)</label>
            <input
              type="number"
              step="0.1"
              value={formData.doseMg}
              onChange={e => setFormData({ ...formData, doseMg: e.target.value })}
              className="w-full glass-card px-4 py-3 text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/30"
              placeholder="e.g., 10"
            />
          </div>

          {/* Notes */}
          <div>
            <label className="block text-sm text-white/90 mb-2">Notes</label>
            <textarea
              value={formData.notes}
              onChange={e => setFormData({ ...formData, notes: e.target.value })}
              rows={3}
              className="w-full glass-card px-4 py-3 text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/30 resize-none"
              placeholder="How are you feeling? What's the context?"
            />
          </div>

          {/* Submit */}
          <button
            type="submit"
            className="w-full bg-white text-gray-900 font-bold py-4 rounded-2xl active:scale-95 transition-transform"
          >
            Save Session
          </button>
        </form>
      </div>
    </div>
  );
}

export default function LogSessionPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-vape-gradient flex items-center justify-center">
        <div className="text-white">Loading...</div>
      </div>
    }>
      <LogSessionContent />
    </Suspense>
  );
}
