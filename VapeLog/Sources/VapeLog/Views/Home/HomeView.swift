import SwiftUI

/// A simple landing screen that highlights the core flows of the cannabis tracking app.
struct HomeView: View {
    @State private var navigationPath = NavigationPath()

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

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        header
                        actionButtons
                    }
                    .padding(.vertical, 40)
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("VapeLog")
            .navigationDestination(for: NavigationDestination.self) { destination in
                destination.view
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome back")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))

            Text("Discover your ideal terpene and cannabinoid profile")
                .font(.title.bold())
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("Track each session, learn about terpene effects, and review how different strains support your desired mood and relief goals.")
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(24)
        .background(.ultraThinMaterial.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.1))
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 20) {
            HomeActionButton(
                title: "Log a Session",
                subtitle: "Record the strain, dose, and how it made you feel.",
                systemImage: "leaf.fill"
            ) {
                navigationPath.append(NavigationDestination.sessionLogging)
            }

            HomeActionButton(
                title: "Terpene Explorer",
                subtitle: "Browse terpene profiles and learn their effects.",
                systemImage: "aqi.medium"
            ) {
                navigationPath.append(NavigationDestination.terpeneExplorer)
            }

            HomeActionButton(
                title: "Insights & Trends",
                subtitle: "Review patterns in your usage and wellness goals.",
                systemImage: "chart.line.uptrend.xyaxis"
            ) {
                navigationPath.append(NavigationDestination.insights)
            }
        }
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

// MARK: - Navigation
enum NavigationDestination: Hashable {
    case sessionLogging
    case terpeneExplorer
    case insights

    @ViewBuilder
    var view: some View {
        switch self {
        case .sessionLogging:
            SessionLoggingView()
        case .terpeneExplorer:
            TerpeneExplorerView()
        case .insights:
            InsightsView()
        }
    }
}

#Preview {
    HomeView()
}
