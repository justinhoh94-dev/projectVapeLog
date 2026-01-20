import SwiftUI

/// Analytics and insights dashboard showing usage patterns
struct InsightsView: View {
    @State private var sessionCount: Int = 0
    @State private var hasEnoughData: Bool = false

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    statsSection
                    recommendationsSection
                    patternsSection
                }
                .padding(24)
            }
        }
        .navigationTitle("Insights & Trends")
        .onAppear {
            loadInsights()
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(red: 0.10, green: 0.24, blue: 0.20),
                    Color(red: 0.04, green: 0.09, blue: 0.15)
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("Your Progress")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                StatCard(
                    title: "Sessions Logged",
                    value: "\(sessionCount)",
                    icon: "leaf.fill"
                )

                StatCard(
                    title: "ML Status",
                    value: hasEnoughData ? "Active" : "Learning",
                    icon: "brain.head.profile"
                )
            }

            if !hasEnoughData {
                VStack(spacing: 8) {
                    Text("Keep tracking to unlock personalized insights")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))

                    ProgressView(value: Double(sessionCount), total: 15)
                        .tint(.white)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)

                    Text("\(max(0, 15 - sessionCount)) more sessions needed")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
            }
        }
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Recommendations")
                .font(.headline)
                .foregroundColor(.white)

            if hasEnoughData {
                ForEach(0..<3) { index in
                    RecommendationCard(
                        productName: "Sample Product \(index + 1)",
                        confidence: ["High", "Medium", "Low"][index],
                        reason: "Based on your positive responses to similar terpene profiles"
                    )
                }
            } else {
                EmptyStateCard(
                    icon: "chart.line.uptrend.xyaxis",
                    message: "Log at least 15 sessions to get personalized recommendations"
                )
            }
        }
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Usage Patterns")
                .font(.headline)
                .foregroundColor(.white)

            if hasEnoughData {
                VStack(spacing: 12) {
                    PatternRow(label: "Most Active Time", value: "Evening (7-9 PM)")
                    PatternRow(label: "Favorite Terpene", value: "Myrcene")
                    PatternRow(label: "Best Results", value: "Relaxation & Sleep")
                }
            } else {
                EmptyStateCard(
                    icon: "calendar",
                    message: "Pattern analysis available after 15+ sessions"
                )
            }
        }
    }

    private func loadInsights() {
        // TODO: Load from database
        sessionCount = UserDefaults.standard.integer(forKey: "sessionCount")
        hasEnoughData = sessionCount >= 15
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)

            Text(value)
                .font(.title.bold())
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

struct RecommendationCard: View {
    let productName: String
    let confidence: String
    let reason: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(productName)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text(confidence)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(confidenceColor)
                    )
            }

            Text(reason)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.12))
        )
    }

    private var confidenceColor: Color {
        switch confidence {
        case "High": return Color.green.opacity(0.6)
        case "Medium": return Color.yellow.opacity(0.6)
        case "Low": return Color.orange.opacity(0.6)
        default: return Color.gray.opacity(0.6)
        }
    }
}

struct PatternRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct EmptyStateCard: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.white.opacity(0.5))

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
}
