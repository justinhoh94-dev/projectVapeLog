import SwiftUI

@main
struct VapeLogApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var sessionCount: Int = 0

    init() {
        // Load persisted state from UserDefaults
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.sessionCount = UserDefaults.standard.integer(forKey: "sessionCount")
    }

    func incrementSessionCount() {
        sessionCount += 1
        UserDefaults.standard.set(sessionCount, forKey: "sessionCount")
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
