import Foundation

/// On-device analytics engine for personalized recommendations
/// Future: Will implement regularized linear regression models
final class AnalyticsEngine {
    static let shared = AnalyticsEngine()
    private let database = DatabaseService.shared

    private init() {}

    // MARK: - ML Readiness
    private let minimumSessionsForML = 15

    func isMLReady() -> Bool {
        do {
            let count = try database.getSessionCountForMLReadiness()
            return count >= minimumSessionsForML
        } catch {
            print("Error checking ML readiness: \(error)")
            return false
        }
    }

    func sessionsUntilMLReady() -> Int {
        do {
            let count = try database.getSessionCountForMLReadiness()
            return max(0, minimumSessionsForML - count)
        } catch {
            return minimumSessionsForML
        }
    }

    // MARK: - Simple Recommendations (Pre-ML)
    /// Returns products ranked by average positive effects
    func getTopProducts(limit: Int = 3) -> [ProductRecommendation] {
        do {
            let products = try database.getAllProducts()

            var recommendations: [ProductRecommendation] = []

            for product in products {
                guard let productId = product.id,
                      let effects = try database.getAverageEffectsForProduct(productId: productId) else {
                    continue
                }

                // Simple scoring: positive effects minus negative effects
                let score = effects.positive - effects.negative

                recommendations.append(ProductRecommendation(
                    product: product,
                    score: score,
                    confidence: calculateConfidence(for: productId),
                    reason: generateReason(product: product, effects: effects)
                ))
            }

            return recommendations
                .sorted { $0.score > $1.score }
                .prefix(limit)
                .map { $0 }

        } catch {
            print("Error generating recommendations: \(error)")
            return []
        }
    }

    private func calculateConfidence(for productId: Int64) -> Confidence {
        do {
            let sessions = try database.getAllSessions()
                .filter { $0.productId == productId }

            let sessionCount = sessions.count

            if sessionCount >= 5 {
                return .high
            } else if sessionCount >= 2 {
                return .medium
            } else {
                return .low
            }
        } catch {
            return .low
        }
    }

    private func generateReason(product: Product, effects: (positive: Double, negative: Double)) -> String {
        let dominantTerpenes = product.dominantTerpenes.prefix(2).joined(separator: " and ")

        if !dominantTerpenes.isEmpty {
            return "Based on your positive responses to \(dominantTerpenes)"
        } else if let thc = product.thcPercent {
            return "Based on \(String(format: "%.1f", thc))% THC matching your preferences"
        } else {
            return "Based on your past experiences with similar products"
        }
    }

    // MARK: - Usage Patterns
    func getMostCommonTimeOfDay() -> String? {
        do {
            let sessions = try database.getAllSessions()
            guard !sessions.isEmpty else { return nil }

            let calendar = Calendar.current
            var hourCounts: [Int: Int] = [:]

            for session in sessions {
                let hour = calendar.component(.hour, from: session.dateTime)
                hourCounts[hour, default: 0] += 1
            }

            guard let mostCommonHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
                return nil
            }

            switch mostCommonHour {
            case 0..<6:
                return "Late Night (12-6 AM)"
            case 6..<12:
                return "Morning (6 AM-12 PM)"
            case 12..<17:
                return "Afternoon (12-5 PM)"
            case 17..<21:
                return "Evening (5-9 PM)"
            default:
                return "Night (9 PM-12 AM)"
            }
        } catch {
            print("Error analyzing time patterns: \(error)")
            return nil
        }
    }

    func getFavoriteTerpene() -> String? {
        do {
            let products = try database.getAllProducts()
            var terpeneTotals: [String: Double] = [:]

            for product in products {
                guard let productId = product.id else { continue }

                // Weight by positive effects
                let effects = try database.getAverageEffectsForProduct(productId: productId)
                let weight = effects?.positive ?? 1.0

                // Sum weighted terpene values
                if let myrcene = product.myrcene {
                    terpeneTotals["Myrcene", default: 0] += myrcene * weight
                }
                if let limonene = product.limonene {
                    terpeneTotals["Limonene", default: 0] += limonene * weight
                }
                if let pinene = product.pinene {
                    terpeneTotals["Pinene", default: 0] += pinene * weight
                }
                if let caryophyllene = product.caryophyllene {
                    terpeneTotals["Caryophyllene", default: 0] += caryophyllene * weight
                }
                if let humulene = product.humulene {
                    terpeneTotals["Humulene", default: 0] += humulene * weight
                }
                if let linalool = product.linalool {
                    terpeneTotals["Linalool", default: 0] += linalool * weight
                }
                if let terpinolene = product.terpinolene {
                    terpeneTotals["Terpinolene", default: 0] += terpinolene * weight
                }
                if let ocimene = product.ocimene {
                    terpeneTotals["Ocimene", default: 0] += ocimene * weight
                }
            }

            return terpeneTotals.max(by: { $0.value < $1.value })?.key
        } catch {
            print("Error analyzing favorite terpene: \(error)")
            return nil
        }
    }

    func getBestResultsFor() -> String {
        // This would be more sophisticated with real ML
        // For now, return a placeholder
        return "Relaxation & Sleep"
    }
}

// MARK: - Supporting Types
struct ProductRecommendation {
    let product: Product
    let score: Double
    let confidence: Confidence
    let reason: String
}

enum Confidence: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}
