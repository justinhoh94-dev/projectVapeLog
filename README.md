# VapeLog - Cannabis Usage Tracker

A privacy-first iOS app for tracking cannabis usage with ML-powered label scanning and personalized recommendations.

## Features

### ✅ Implemented (v0.1)

- **Home Screen** - Polished glassmorphic UI with navigation
- **ML Label Scanning** - Camera-based OCR to extract cannabinoid and terpene data from product labels
- **Terpene Explorer** - Educational content about terpenes and their effects
- **Insights Dashboard** - Usage patterns and basic analytics
- **Data Models** - Product, Session, and CheckIn entities
- **Database Layer** - GRDB-based local storage with migrations
- **Analytics Foundation** - Pre-ML recommendation engine

### 🚧 Coming Soon

- **Session Logging** - Complete form for recording sessions with dose, context, and mood
- **Check-in System** - Timed reminders to record effects at 30, 60, and 120 minutes
- **ML Models** - Regularized linear regression for effect prediction
- **Data Export** - CSV/JSON export with optional encrypted cloud backup
- **Notifications** - Background reminders for check-ins

## Project Structure

```
VapeLog/
├── Sources/VapeLog/
│   ├── App/
│   │   └── VapeLogApp.swift          # App entry point
│   ├── Views/
│   │   ├── Home/
│   │   │   └── HomeView.swift         # Main landing screen
│   │   ├── Logging/
│   │   │   ├── SessionLoggingView.swift
│   │   │   └── LabelScannerView.swift # ML camera scanner
│   │   ├── TerpeneExplorer/
│   │   │   └── TerpeneExplorerView.swift
│   │   └── Insights/
│   │       └── InsightsView.swift     # Analytics dashboard
│   ├── Models/
│   │   ├── Product.swift              # Cannabis product entity
│   │   ├── Session.swift              # Usage session entity
│   │   ├── CheckIn.swift              # Effect check-in entity
│   │   └── Terpene.swift              # Reference terpene data
│   ├── Services/
│   │   └── DatabaseService.swift      # GRDB database layer
│   ├── Analytics/
│   │   └── AnalyticsEngine.swift      # ML recommendation engine
│   └── Resources/
│       └── Info.plist                 # Camera & notification permissions
├── Package.swift                       # Swift Package Manager config
└── README.md
```

## Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **GRDB** - Type-safe SQLite wrapper for local storage
- **Vision Framework** - On-device OCR for label scanning
- **AVFoundation** - Camera capture for ML scanning
- **Core ML** - Future: On-device ML models for predictions

## Setup Instructions

### Prerequisites

- macOS with Xcode 15.0+
- iOS 17.0+ target device/simulator
- Swift 5.9+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd projectVapeLog
   ```

2. **Open in Xcode**
   ```bash
   cd VapeLog
   open Package.swift
   ```

   Or use Xcode to open `VapeLog/Package.swift`

3. **Resolve dependencies**
   - Xcode will automatically resolve Swift Package Manager dependencies
   - GRDB.swift will be fetched from GitHub

4. **Build and run**
   - Select your target device/simulator
   - Press `Cmd+R` to build and run

### Camera Permissions

The app requires camera access for ML label scanning. Permissions are configured in `Info.plist`:

- **NSCameraUsageDescription** - "VapeLog needs camera access to scan cannabis product labels..."
- **NSPhotoLibraryUsageDescription** - For saving scanned labels (optional)
- **NSUserNotificationsUsageDescription** - For check-in reminders (coming soon)

## Usage

### Scanning a Product Label

1. Tap **"Log a Session"** from the home screen
2. Tap **"Use Camera to Scan"**
3. Position the product label within the camera frame
4. Tap the capture button
5. The app will extract:
   - Cannabinoid percentages (THC, CBD, CBG, THCV)
   - Terpene profiles (Myrcene, Limonene, Pinene, etc.)
   - Raw text data

### Learning About Terpenes

1. Tap **"Terpene Explorer"**
2. Browse educational cards for each major terpene
3. Learn about aromas, effects, and therapeutic benefits

### Viewing Insights

1. Tap **"Insights & Trends"**
2. View session count and ML readiness status
3. After 15+ sessions, unlock:
   - Personalized recommendations with confidence levels
   - Usage pattern analysis
   - Favorite terpene profiles

## Privacy & Security

- **Local-First** - All data stored locally in SQLite
- **No Tracking** - No analytics or third-party telemetry
- **On-Device ML** - All computations happen locally
- **Optional Backup** - Future: Encrypted cloud backup (opt-in only)

## Database Schema

### Products Table
- Cannabinoid percentages (THC, CBD, CBG, THCV)
- Terpene profiles (8 major terpenes + custom)
- Product metadata (name, brand, type, route)

### Sessions Table
- Product reference
- Dose and timing
- Context (location, company, caffeine, alcohol, food, sleep)
- Pre-session mood and stress levels

### Check-ins Table
- Session reference
- Time offset (30, 60, or 120 minutes)
- Positive effects (7 dimensions)
- Negative effects (8 dimensions)

## ML Features (Planned)

### Effect Prediction Model
- **Algorithm**: Regularized linear regression (L2/L1)
- **Features**: Terpene vectors, cannabinoid vectors, context
- **Targets**: Positive and negative effect composites
- **Training**: Incremental on-device (requires 15+ sessions)

### Recommendation Engine
- **Scoring**: Feature importance + confidence bands
- **Confidence Levels**: High (5+ sessions), Medium (2-4), Low (1)
- **Explanations**: One-sentence reason with key drivers

## Development Roadmap

See `AGENTS.md` for detailed agent roles and development plan.

### v0.1 - Foundation ✅
- Home screen UI
- ML camera scanner
- Basic navigation
- Database schema
- Analytics foundation

### v0.2 - Core Features 🚧
- Complete session logging form
- Check-in system with notifications
- Manual product entry
- Data export

### v0.3 - ML Integration 📋
- Feature engineering pipeline
- Regularized regression models
- Recommendation scoring
- Bootstrap confidence estimation

### v1.0 - MVP Release 🎯
- Full offline functionality
- On-device ML models
- Encrypted backups (optional)
- Comprehensive testing

## Contributing

This project follows a multi-agent development approach. See `AGENTS.md` for role definitions:

- Product Owner Agent
- Data Modeler Agent
- Analytics Agent
- iOS Agent
- QA Agent
- Privacy/Security Agent
- Docs Agent

## License

[Add license information]

## Support

For issues or questions, please open a GitHub issue.

---

**Built with privacy and wellness in mind** 🌿
