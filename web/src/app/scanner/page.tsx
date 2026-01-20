'use client';

import { useState, useRef, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Camera, X, Loader2, CheckCircle } from 'lucide-react';
import { scanImage, mockScan, ScanResult } from '@/lib/scanner';

export default function ScannerPage() {
  const router = useRouter();
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [isScanning, setIsScanning] = useState(false);
  const [scanResult, setScanResult] = useState<ScanResult | null>(null);
  const [error, setError] = useState<string>('');
  const [cameraReady, setCameraReady] = useState(false);

  useEffect(() => {
    startCamera();
    return () => {
      stopCamera();
    };
  }, []);

  const startCamera = async () => {
    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment', width: { ideal: 1920 }, height: { ideal: 1080 } }
      });

      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
        setStream(mediaStream);
        setCameraReady(true);
      }
    } catch (err) {
      console.error('Camera error:', err);
      setError('Unable to access camera. Please ensure camera permissions are granted.');
    }
  };

  const stopCamera = () => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
  };

  const captureAndScan = async () => {
    if (!videoRef.current || !canvasRef.current) return;

    setIsScanning(true);
    setError('');

    try {
      const video = videoRef.current;
      const canvas = canvasRef.current;
      const context = canvas.getContext('2d');

      if (!context) throw new Error('Canvas context not available');

      // Set canvas dimensions to match video
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;

      // Draw video frame to canvas
      context.drawImage(video, 0, 0);

      // Convert to blob for OCR
      const blob = await new Promise<Blob>((resolve, reject) => {
        canvas.toBlob(blob => {
          if (blob) resolve(blob);
          else reject(new Error('Failed to create image blob'));
        }, 'image/jpeg', 0.95);
      });

      // Perform OCR scan
      const result = await scanImage(blob);

      setScanResult(result);
    } catch (err) {
      console.error('Scan error:', err);
      setError('Failed to scan image. Please try again.');
    } finally {
      setIsScanning(false);
    }
  };

  const useMockScan = () => {
    setScanResult(mockScan());
  };

  const useResult = () => {
    if (!scanResult) return;

    // Store in localStorage for product creation
    localStorage.setItem('pendingScanResult', JSON.stringify(scanResult));
    router.push('/log-session?fromScan=true');
  };

  return (
    <div className="min-h-screen bg-vape-gradient">
      {/* Header */}
      <header className="sticky top-0 z-10 bg-black/30 backdrop-blur-sm border-b border-white/10">
        <div className="flex items-center justify-between px-6 py-4">
          <h1 className="text-xl font-semibold text-white">Scan Label</h1>
          <button
            onClick={() => router.back()}
            className="text-white/80 hover:text-white"
          >
            <X className="w-6 h-6" />
          </button>
        </div>
      </header>

      {/* Camera View */}
      <div className="relative w-full h-[60vh] bg-black">
        <video
          ref={videoRef}
          autoPlay
          playsInline
          muted
          className="w-full h-full object-cover"
        />

        {/* Scan Frame Overlay */}
        {cameraReady && !scanResult && (
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="relative">
              <div className="w-80 h-52 border-4 border-white rounded-3xl shadow-2xl" />
              <div className="absolute -top-12 left-1/2 -translate-x-1/2 bg-black/70 px-4 py-2 rounded-full">
                <p className="text-white text-sm whitespace-nowrap">
                  Position label within frame
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Error Message */}
        {error && (
          <div className="absolute top-4 left-4 right-4 bg-red-500/90 text-white px-4 py-3 rounded-xl text-sm">
            {error}
          </div>
        )}
      </div>

      {/* Hidden canvas for image capture */}
      <canvas ref={canvasRef} className="hidden" />

      {/* Controls */}
      <div className="px-6 py-8">
        {!scanResult ? (
          <div className="space-y-4">
            {/* Capture Button */}
            <button
              onClick={captureAndScan}
              disabled={isScanning || !cameraReady}
              className="w-full bg-white text-gray-900 font-semibold py-4 rounded-2xl flex items-center justify-center gap-3 disabled:opacity-50 disabled:cursor-not-allowed active:scale-95 transition-transform"
            >
              {isScanning ? (
                <>
                  <Loader2 className="w-5 h-5 animate-spin" />
                  Analyzing label...
                </>
              ) : (
                <>
                  <Camera className="w-5 h-5" />
                  Capture & Scan
                </>
              )}
            </button>

            {/* Mock Scan Button (for testing) */}
            <button
              onClick={useMockScan}
              className="w-full glass-button text-white text-sm py-3 rounded-2xl"
            >
              Use Demo Data (Testing)
            </button>
          </div>
        ) : (
          /* Scan Results */
          <div className="glass-card p-6">
            <div className="flex items-center gap-3 mb-4">
              <CheckCircle className="w-6 h-6 text-green-400" />
              <h3 className="text-xl font-bold text-white">Scan Complete!</h3>
            </div>

            {/* Cannabinoids */}
            {Object.keys(scanResult.cannabinoids).length > 0 && (
              <div className="mb-4">
                <p className="text-sm text-white/70 mb-2">Cannabinoids Found:</p>
                <div className="flex flex-wrap gap-2">
                  {Object.entries(scanResult.cannabinoids).map(([name, value]) => (
                    <span
                      key={name}
                      className="bg-white/20 px-3 py-1 rounded-full text-sm text-white"
                    >
                      {name}: {value.toFixed(1)}%
                    </span>
                  ))}
                </div>
              </div>
            )}

            {/* Terpenes */}
            {Object.keys(scanResult.terpenes).length > 0 && (
              <div className="mb-6">
                <p className="text-sm text-white/70 mb-2">Terpenes Found:</p>
                <div className="flex flex-wrap gap-2">
                  {Object.entries(scanResult.terpenes).map(([name, value]) => (
                    <span
                      key={name}
                      className="bg-white/20 px-3 py-1 rounded-full text-sm text-white"
                    >
                      {name}: {value.toFixed(1)}%
                    </span>
                  ))}
                </div>
              </div>
            )}

            {/* Action Buttons */}
            <div className="space-y-3">
              <button
                onClick={useResult}
                className="w-full bg-green-500 text-white font-semibold py-4 rounded-2xl active:scale-95 transition-transform"
              >
                Use This Data
              </button>
              <button
                onClick={() => setScanResult(null)}
                className="w-full glass-button text-white py-3 rounded-2xl"
              >
                Scan Again
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
