import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Overview Section
                HelpSection(title: "Overview", icon: "info.circle") {
                    Text("HitTracker helps you track and analyze where batters hit the ball during softball games. Record hit locations, pitch information, and view spray charts to identify hitting patterns.")
                }

                // Setting Up Your Team
                HelpSection(title: "Setting Up Your Team", icon: "person.3") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When you first open the app, you'll set up your team:")
                        Text("1. Enter your **Team Name**")
                        Text("2. Add players with their **Name** and **Number**")
                        Text("3. Players appear in lineup order (you can reorder later)")
                        Text("4. Tap **Start Tracking** when ready")
                    }
                }

                // Tracking Hits
                HelpSection(title: "Tracking Hits", icon: "sportscourt") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("On the Track screen:")
                        Text("1. **Select the batter** using the scrolling selector at the top")
                        Text("2. **Tap on the field** where the ball was hit")
                        Text("3. Choose the **hit type**:")
                        Text("   • Fly Ball - hit high in the air")
                        Text("   • Line Drive - hit hard and flat")
                        Text("   • Pop Up - hit high but not far")
                        Text("   • Grounder - hit on the ground")
                        Text("4. Optionally add **pitch information**:")
                        Text("   • Pitch Type: Fastball, Change Up, Curve, Rise, Drop")
                        Text("   • Location: High, Low, Inside, Outside, Middle")
                        Text("5. Tap **Save** to record the hit")
                    }
                }

                // Understanding the Display
                HelpSection(title: "Understanding the Display", icon: "eye") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When a batter is selected, you'll see:")
                        Text("• **Pitch stats bar** - shows what pitches they've hit successfully")
                        Text("• **Colored dots** on the field showing previous hit locations:")
                        Text("   • 🔵 Blue = Fly Ball")
                        Text("   • 🔴 Red = Line Drive")
                        Text("   • 🟣 Purple = Pop Up")
                        Text("   • 🟠 Orange = Grounder")
                    }
                }

                // Viewing Results
                HelpSection(title: "Viewing Results", icon: "chart.bar") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The Results tab shows statistics:")
                        Text("• **Team Overview** - total hits and per-player counts")
                        Text("• **Player Stats** - select a player to see:")
                        Text("   • Total hits")
                        Text("   • Hit type breakdown")
                        Text("   • Pitch type/location patterns")
                        Text("   • Mini spray chart")
                    }
                }

                // Managing Your Team
                HelpSection(title: "Managing Your Team", icon: "gear") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("In Settings, you can:")
                        Text("• **Change team name** - tap to edit")
                        Text("• **Add players** - tap Add Player")
                        Text("• **Reorder lineup** - drag players using the handle")
                        Text("• **Remove players** - swipe left to delete")
                        Text("• **Clear player hits** - remove one player's data")
                        Text("• **Clear all hits** - reset all hit data")
                        Text("• **Add team logo** - appears in exports")
                    }
                }

                // Tips
                HelpSection(title: "Tips", icon: "lightbulb") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Track pitch info to see what pitches each batter handles best")
                        Text("• Review spray charts before games to scout tendencies")
                        Text("• Use Dark Mode for visibility at evening games")
                        Text("• The lineup order matches your batting order - reorder as needed")
                    }
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }

            content
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
