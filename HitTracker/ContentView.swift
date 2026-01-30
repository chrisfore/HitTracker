import SwiftUI

struct ContentView: View {
    @StateObject private var database = DatabaseManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    var body: some View {
        Group {
            if hasCompletedSetup && database.hasTeamSetup {
                TabView {
                    TrackingView()
                        .tabItem {
                            Label("Track", systemImage: "sportscourt")
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
