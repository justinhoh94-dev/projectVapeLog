# VapeLog Web - Cannabis Usage Tracker

A mobile-first Progressive Web App (PWA) for tracking cannabis usage with ML-powered label scanning. Access from any device's browser, works offline, and install to your home screen like a native app.

## 🚀 Features

### ✅ Fully Implemented

- **📱 Mobile-First Design** - Responsive UI optimized for phone screens
- **📸 ML Camera Scanner** - Use your phone's camera to scan product labels
- **🤖 OCR Text Recognition** - Automatically extract cannabinoid & terpene data using Tesseract.js
- **💾 Offline-First Storage** - All data stored locally using IndexedDB (Dexie)
- **🌿 Terpene Education** - Learn about 8 major terpenes and their effects
- **📊 Analytics Dashboard** - Track usage patterns and get recommendations
- **🔒 Privacy-First** - Zero external data transmission, everything stays on your device
- **📲 PWA Support** - Install to home screen for app-like experience
- **🎨 Glassmorphic UI** - Beautiful dark green gradient with glass effects

### Core Pages

1. **Home** - Dashboard with quick access to all features
2. **Session Logger** - Record sessions with camera scanning
3. **Scanner** - Camera-based OCR for label data extraction
4. **Terpene Explorer** - Educational cards for each terpene
5. **Insights** - Analytics and ML-powered recommendations

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Next.js 14 (App Router) |
| Language | TypeScript |
| UI | React 18 + Tailwind CSS |
| Database | Dexie (IndexedDB wrapper) |
| OCR | Tesseract.js |
| Camera | WebRTC MediaDevices API |
| Icons | Lucide React |
| Animations | Framer Motion |

## 📋 Prerequisites

- Node.js 18+ and npm/yarn/pnpm
- Modern browser with camera access (Chrome, Safari, Firefox)
- HTTPS required for camera API (use localhost or deploy to HTTPS)

## 🚀 Getting Started

### Installation

```bash
# Navigate to web directory
cd web

# Install dependencies
npm install
# or
yarn install
# or
pnpm install
```

### Development

```bash
# Start development server
npm run dev

# Open http://localhost:3000 in your browser
```

### Build for Production

```bash
# Create optimized production build
npm run build

# Start production server
npm start
```

### Deploy

#### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

Or connect your GitHub repo to Vercel for automatic deployments.

#### Netlify

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy --prod
```

#### Other Platforms

Build the app and deploy the `out/` or `.next/` directory to any static hosting:

- Cloudflare Pages
- AWS Amplify
- GitHub Pages (with static export)
- Firebase Hosting

## 📱 Using on Your Phone

### Install as PWA (iPhone)

1. Open https://your-deployed-url.com in Safari
2. Tap the Share button (square with arrow)
3. Scroll down and tap "Add to Home Screen"
4. Tap "Add" in the top right
5. VapeLog will appear on your home screen like a native app!

### Install as PWA (Android)

1. Open https://your-deployed-url.com in Chrome
2. Tap the three-dot menu
3. Tap "Install app" or "Add to Home screen"
4. Follow the prompts
5. VapeLog will appear in your app drawer!

### Grant Camera Permissions

When you first use the scanner:

- **iOS Safari**: Tap "Allow" when prompted for camera access
- **Android Chrome**: Tap "Allow" when prompted

Note: Camera API requires HTTPS (secure connection). It works on localhost for development.

## 🎯 Usage Guide

### Scanning a Product Label

1. Tap **"Log a Session"** from home
2. Tap **"Use Camera to Scan Label"**
3. Position the product label within the white frame
4. Tap **"Capture & Scan"**
5. Wait for OCR processing (~2-5 seconds)
6. Review extracted data (THC%, CBD%, terpenes)
7. Tap **"Use This Data"** to auto-fill the form
8. Complete product details and save

### Manual Entry

1. Tap **"Log a Session"**
2. Fill in product information manually
3. Add cannabinoid percentages
4. Include dose and notes
5. Tap **"Save Session"**

### Learning About Terpenes

1. Tap **"Terpene Explorer"**
2. Scroll through 8 terpene cards
3. Read about aromas, effects, and descriptions
4. Use this knowledge when choosing products

### Viewing Insights

1. Tap **"Insights & Trends"**
2. See session count and ML readiness
3. After 15+ sessions:
   - Get top 3 product recommendations
   - See usage patterns (time of day, favorite terpenes)
   - View confidence levels (High/Medium/Low)

## 🗂️ Project Structure

```
web/
├── src/
│   ├── app/                      # Next.js App Router pages
│   │   ├── page.tsx              # Home page
│   │   ├── layout.tsx            # Root layout
│   │   ├── globals.css           # Global styles
│   │   ├── scanner/
│   │   │   └── page.tsx          # Camera scanner page
│   │   ├── log-session/
│   │   │   └── page.tsx          # Session logging form
│   │   ├── terpenes/
│   │   │   └── page.tsx          # Terpene education
│   │   └── insights/
│   │       └── page.tsx          # Analytics dashboard
│   └── lib/
│       ├── db.ts                 # Dexie/IndexedDB layer
│       ├── scanner.ts            # OCR & data extraction
│       └── terpenes.ts           # Terpene reference data
├── public/
│   ├── manifest.json             # PWA manifest
│   └── icon-192.png              # App icon
├── package.json
├── tsconfig.json
├── tailwind.config.js
└── next.config.js
```

## 🔐 Privacy & Security

### Data Storage

- **100% Local** - All data stored in browser's IndexedDB
- **No Backend** - No server, no API calls, no external storage
- **Device-Only** - Data never leaves your device
- **Offline-First** - Full functionality without internet

### Camera Usage

- Camera access is **only** used during label scanning
- No photos are uploaded or stored externally
- Captured images are processed locally and discarded
- You can revoke camera permissions anytime in browser settings

### Data Export

```javascript
// Export all data as JSON
import { exportData } from '@/lib/db';
const jsonData = await exportData();
console.log(jsonData); // Download or backup manually
```

## 🧪 Testing

### Test OCR Without Camera

The scanner includes a "Use Demo Data" button that provides mock scan results:

```javascript
{
  cannabinoids: { THC: 23.5, CBD: 0.8, CBG: 1.2 },
  terpenes: { Myrcene: 2.1, Limonene: 1.5, Caryophyllene: 0.9 },
  rawText: "..."
}
```

### Browser DevTools

Test different screen sizes:
- iPhone 12 Pro (390x844)
- iPhone SE (375x667)
- Pixel 5 (393x851)
- iPad (768x1024)

## 🐛 Troubleshooting

### Camera Not Working

**Problem**: "Unable to access camera" error

**Solutions**:
1. Ensure you're on HTTPS (or localhost)
2. Check browser camera permissions
3. Try different browser (Chrome recommended)
4. On iOS, use Safari (Chrome iOS uses Safari engine)

### OCR Not Detecting Text

**Problem**: Scan completes but no data extracted

**Solutions**:
1. Ensure label has good lighting
2. Hold phone steady during capture
3. Position label within the white frame
4. Use high contrast labels (dark text on light background)
5. Try the "Use Demo Data" button to test the flow

### App Not Installing to Home Screen

**Problem**: PWA install option not appearing

**Solutions**:
1. Ensure you're on HTTPS (required for PWA)
2. iOS: Use Safari (not Chrome)
3. Android: Use Chrome (recommended)
4. Check manifest.json is accessible

## 🔄 Future Enhancements

- [ ] Push notifications for check-in reminders
- [ ] Advanced ML models (TensorFlow.js)
- [ ] Data sync across devices (optional, encrypted)
- [ ] More detailed analytics charts
- [ ] Social sharing (anonymized data)
- [ ] Integration with health apps

## 📄 License

[Add license information]

## 🤝 Contributing

This project is part of a multi-agent development workflow. See `/AGENTS.md` in the root directory for details.

## 💬 Support

For issues, please open a GitHub issue with:
- Browser and OS version
- Screenshots (if applicable)
- Steps to reproduce

---

**Built with 🌿 and privacy in mind**

**Access VapeLog on your phone now!** → Deploy and scan the QR code
