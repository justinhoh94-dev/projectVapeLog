import SwiftUI

/// A rich landing screen tailored to tracking terpene and cannabinoid experiences.
struct HomeView: View {
    let snapshot: DashboardSnapshot

    init(snapshot: DashboardSnapshot = .sample) {
        self.snapshot = snapshot
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(red: 0.07, green: 0.18, blue: 0.16),
                    Color(red: 0.03, green: 0.07, blue: 0.12)
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        header
                        snapshotSection
                        lastSessionSection
                        terpeneFocusSection
                        actionButtons
                        reflectionSection
                    }
                    .padding(.vertical, 36)
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("VapeLog")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome back")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))

            Text("Dial in your terpene + cannabinoid sweet spot")
                .font(.title.bold())
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("Today's intention: \(snapshot.dailyFocus)")
                .font(.callout)
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(24)
        .background(.ultraThinMaterial.opacity(0.18))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.1))
        )
    }

    private var snapshotSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Today's Snapshot",
                subtitle: "How your body responded this week"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(snapshot.quickStats) { stat in
                        QuickStatCard(stat: stat)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var lastSessionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Last Session",
                subtitle: "Captured on \(snapshot.lastSession.timestamp)"
            )

            SessionSummaryCard(session: snapshot.lastSession)
        }
    }

    private var terpeneFocusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Your Terpene Focus",
                subtitle: snapshot.preferredProfileSummary
            )

            VStack(spacing: 14) {
                ForEach(snapshot.focusTerpenes) { terpene in
                    TerpeneFocusRow(terpene: terpene)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Keep Exploring",
                subtitle: "Build a library that matches your desired effects"
            )

            VStack(spacing: 18) {
                HomeActionButton(
                    title: "Log New Session",
                    subtitle: "Track strain, delivery method, dose, and outcome in minutes.",
                    systemImage: "square.and.pencil"
                ) {
                    // TODO: Navigate to the session logging flow.
                }

                HomeActionButton(
                    title: "Compare Terpenes",
                    subtitle: "See how different terpene blends shift your mood and body response.",
                    systemImage: "aqi.medium"
                ) {
                    // TODO: Navigate to the terpene comparison toolkit.
                }

                HomeActionButton(
                    title: "Review Insights",
                    subtitle: "Spot trends across cannabinoid ratios, moods, and terpene stacks.",
                    systemImage: "chart.bar.xaxis"
                ) {
                    // TODO: Navigate to usage insights and analytics.
                }
            }
        }
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: snapshot.reflectionPrompt.title,
                subtitle: snapshot.reflectionPrompt.prompt
            )

            Button(action: { /* TODO: Navigate to journal */ }) {
                Label(snapshot.reflectionPrompt.actionTitle, systemImage: snapshot.reflectionPrompt.icon)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.14))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(subtitle)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

/// Displays a quick stat summarizing recent usage patterns.
private struct QuickStatCard: View {
    let stat: DashboardSnapshot.QuickStat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(stat.title.uppercased())
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.65))
            Text(stat.value)
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
            if let context = stat.context {
                Text(context)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(width: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
    }
}

/// Displays the last logged session with terpene and cannabinoid notes.
private struct SessionSummaryCard: View {
    let session: DashboardSnapshot.Session

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.strain)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                    Text(session.intakeMethod)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Text(session.cannabinoidRatio)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.16))
                    )
            }

            VStack(alignment: .leading, spacing: 12) {
                infoRow(
                    icon: "aqi.low",
                    title: "Dominant Terpenes",
                    value: session.terpeneHighlights.joined(separator: " • ")
                )

                infoRow(
                    icon: "sparkle",
                    title: "Felt",
                    value: session.feelings.joined(separator: ", ")
                )

                infoRow(
                    icon: "heart.text.square",
                    title: "Notes",
                    value: session.experienceNotes
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// Shows the confidence in how a terpene supports the user's desired outcomes.
private struct TerpeneFocusRow: View {
    let terpene: DashboardSnapshot.TerpeneFocus

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(terpene.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(terpene.primaryFeeling)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Text("Confidence \(Int(terpene.confidence * 100))%")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.75))
            }

            Text(terpene.description)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.75))

            ProgressView(value: terpene.confidence)
                .progressViewStyle(.linear)
                .tint(Color.green.opacity(0.8))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }
}

/// A reusable stylized button that conveys key actions on the home screen.
struct HomeActionButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 56, height: 56)

                    Image(systemName: systemImage)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
        }
        .buttonStyle(HomeButtonStyle())
    }
}

/// Provides a glassmorphic button style to match the app's calming aesthetic.
struct HomeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.16 : 0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(configuration.isPressed ? 0.35 : 0.25), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Dashboard Snapshot

/// View data describing the current state of the user's cannabis journey.
struct DashboardSnapshot {
    struct QuickStat: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let context: String?
    }

    struct Session {
        let strain: String
        let intakeMethod: String
        let timestamp: String
        let terpeneHighlights: [String]
        let cannabinoidRatio: String
        let feelings: [String]
        let experienceNotes: String
    }

    struct TerpeneFocus: Identifiable {
        let id = UUID()
        let name: String
        let primaryFeeling: String
        let description: String
        let confidence: Double
    }

    struct ReflectionPrompt {
        let title: String
        let prompt: String
        let actionTitle: String
        let icon: String
    }

    let dailyFocus: String
    let quickStats: [QuickStat]
    let lastSession: Session
    let preferredProfileSummary: String
    let focusTerpenes: [TerpeneFocus]
    let reflectionPrompt: ReflectionPrompt
}

extension DashboardSnapshot {
    static let sample = DashboardSnapshot(
        dailyFocus: "Grounded creativity with clear-headed relief",
        quickStats: [
            .init(
                title: "Sessions",
                value: "3 logged",
                context: "This week"
            ),
            .init(
                title: "Top Terpene",
                value: "Limonene",
                context: "Shows up in 68% of feel-good sessions"
            ),
            .init(
                title: "Best Ratio",
                value: "THC 16% / CBD 4%",
                context: "Balanced focus without anxious spikes"
            )
        ],
        lastSession: .init(
            strain: "Golden Pineapple",
            intakeMethod: "0.15g cartridge • Microdose",
            timestamp: "Last night",
            terpeneHighlights: ["Limonene", "Beta-Caryophyllene"],
            cannabinoidRatio: "THC 18% | CBD 3%",
            feelings: ["Uplifted", "Focused", "Body at ease"],
            experienceNotes: "Kept chatter minimal and boosted creative flow for 90 minutes. Pairing with a light snack avoided dry mouth."
        ),
        preferredProfileSummary: "Consistent energy with bright citrus terpenes and gentle body relief terpenes.",
        focusTerpenes: [
            .init(
                name: "Limonene",
                primaryFeeling: "Elevated mood + creative spark",
                description: "Helps you feel upbeat and motivated when balanced with low-dose Beta-Caryophyllene.",
                confidence: 0.86
            ),
            .init(
                name: "Beta-Caryophyllene",
                primaryFeeling: "Even-bodied calm",
                description: "Relaxes tension without cloudiness, especially when paired with lower myrcene strains.",
                confidence: 0.72
            ),
            .init(
                name: "Terpinolene",
                primaryFeeling: "Clear-headed focus",
                description: "Supports clean mental energy during daytime sessions and minimizes couch-lock.",
                confidence: 0.63
            )
        ],
        reflectionPrompt: .init(
            title: "Reflect & Refine",
            prompt: "What terpenes supported today's intention? Capture dose, context, and standout sensations.",
            actionTitle: "Add to Journal",
            icon: "square.and.pencil"
        )
    )
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
            HomeView()
                .environment(\.colorScheme, .dark)
        }
    }
}
