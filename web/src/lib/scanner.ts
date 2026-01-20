import { createWorker } from 'tesseract.js';

export interface ScanResult {
  cannabinoids: Record<string, number>;
  terpenes: Record<string, number>;
  rawText: string;
}

export async function scanImage(imageData: string | File): Promise<ScanResult> {
  const worker = await createWorker('eng');

  try {
    const { data: { text } } = await worker.recognize(imageData);

    return extractDataFromText(text);
  } finally {
    await worker.terminate();
  }
}

export function extractDataFromText(text: string): ScanResult {
  const cannabinoids: Record<string, number> = {};
  const terpenes: Record<string, number> = {};

  // Split into lines for processing
  const lines = text.split('\n').map(line => line.trim());

  // Cannabinoid patterns
  const cannabinoidPatterns = {
    THC: /(?:total\s+)?thc[:\s]*(\d+\.?\d*)\s*%?/i,
    CBD: /(?:total\s+)?cbd[:\s]*(\d+\.?\d*)\s*%?/i,
    CBG: /cbg[:\s]*(\d+\.?\d*)\s*%?/i,
    THCV: /thcv[:\s]*(\d+\.?\d*)\s*%?/i,
  };

  // Terpene patterns
  const terpenePatterns = {
    Myrcene: /myrcene[:\s]*(\d+\.?\d*)\s*%?/i,
    Limonene: /limonene[:\s]*(\d+\.?\d*)\s*%?/i,
    Pinene: /(?:alpha-|beta-)?pinene[:\s]*(\d+\.?\d*)\s*%?/i,
    Caryophyllene: /(?:beta-)?caryophyllene[:\s]*(\d+\.?\d*)\s*%?/i,
    Humulene: /humulene[:\s]*(\d+\.?\d*)\s*%?/i,
    Linalool: /linalool[:\s]*(\d+\.?\d*)\s*%?/i,
    Terpinolene: /terpinolene[:\s]*(\d+\.?\d*)\s*%?/i,
    Ocimene: /ocimene[:\s]*(\d+\.?\d*)\s*%?/i,
  };

  // Extract cannabinoids
  for (const line of lines) {
    for (const [name, pattern] of Object.entries(cannabinoidPatterns)) {
      const match = line.match(pattern);
      if (match && match[1]) {
        const value = parseFloat(match[1]);
        if (!isNaN(value) && value >= 0 && value <= 100) {
          cannabinoids[name] = value;
        }
      }
    }

    // Extract terpenes
    for (const [name, pattern] of Object.entries(terpenePatterns)) {
      const match = line.match(pattern);
      if (match && match[1]) {
        const value = parseFloat(match[1]);
        if (!isNaN(value) && value >= 0 && value <= 100) {
          terpenes[name] = value;
        }
      }
    }
  }

  return {
    cannabinoids,
    terpenes,
    rawText: text
  };
}

// Mock scanner for testing without actual camera
export function mockScan(): ScanResult {
  return {
    cannabinoids: {
      THC: 23.5,
      CBD: 0.8,
      CBG: 1.2
    },
    terpenes: {
      Myrcene: 2.1,
      Limonene: 1.5,
      Caryophyllene: 0.9
    },
    rawText: 'Mock scan result\nTHC: 23.5%\nCBD: 0.8%\nCBG: 1.2%\nMyrcene: 2.1%\nLimonene: 1.5%\nCaryophyllene: 0.9%'
  };
}
