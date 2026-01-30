import SwiftUI

struct ContentView: View {
    @StateObject private var database = DatabaseManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    var body: some View {
        Group {
            if hasCompletedSetup {
                TabView {
                    TrackingView()
                        .tabItem {
                            Label("Track", systemImage: "figure.baseball")
                        }

                    ResultsView()
                        .tabItem {
                            Label("Results", systemImage: "chart.bar")
                        }

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .environment(\.horizontalSizeClass, .compact)
            } else {
                TeamSetupView(hasCompletedSetup: $hasCompletedSetup)
            }
        }
        .environmentObject(database)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
