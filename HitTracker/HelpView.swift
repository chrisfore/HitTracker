import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Overview Section
                HelpSection(title: "Overview", icon: "info.circle") {
                    Text("HitTracker helps you scout opponent teams by tracking where their batters hit the ball. Record hit locations, pitch information, and view spray charts to identify hitting patterns and position your defense strategically.")
                }

                // About Scouting Section
                HelpSection(title: "About Scouting", icon: "binoculars") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HitTracker is designed for **scouting opponent teams**.")
                        Text("• Track where opponents hit against YOUR pitchers")
                        Text("• Build spray charts for each opponent batter")
                        Text("• Identify hitting patterns and tendencies")
                        Text("• Use the data to position your defense")
                        Text("\nYour team logo represents YOUR team - you're tracking hits of other teams playing AGAINST you.")
                    }
                }

                // Setting Up Opponent Teams
                HelpSection(title: "Setting Up Opponent Teams", icon: "person.3") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When you first open the app, you'll set up an opponent team to scout:")
                        Text("1. Enter the **Opponent Team Name**")
                        Text("2. Add players with their **Number** (name is optional)")
                        Text("3. Players appear in lineup order (you can reorder later)")
                        Text("4. Tap **Start Tracking** when ready")
                        Text("\nYou can add more opponent teams later in Settings.")
                    }
                }

                // Tracking Hits
                HelpSection(title: "Tracking Hits", icon: "figure.baseball") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("On the Track screen:")
                        Text("1. **Select the opponent team** using the dropdown at the top")
                        Text("2. **Select the batter** using the scrolling selector")
                        Text("3. **Tap on the field** where the ball was hit")
                        Text("4. Choose the **hit type**:")
                        Text("   • Fly Ball - hit high in the air")
                        Text("   • Line Drive - hit hard and flat")
                        Text("   • Pop Up - hit high but not far")
                        Text("   • Grounder - hit on the ground")
                        Text("5. Optionally add **pitch information**:")
                        Text("   • Pitch Type: Fastball, Change Up, Curve, Rise, Drop")
                        Text("   • Location: High, Low, Inside, Outside, Middle")
                        Text("6. Tap **Save** to record the hit")
                    }
                }

                // Understanding the Display
                HelpSection(title: "Understanding the Display", icon: "eye") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When a batter is selected, you'll see:")
                        Text("• **Pitch stats bar** - tap to filter hits by pitch type/location")
                        Text("• **Colored dots** on the field showing previous hit locations:")
                        Text("   • Blue = Fly Ball")
                        Text("   • Red = Line Drive")
                        Text("   • Purple = Pop Up")
                        Text("   • Orange = Grounder")
                        Text("   • Black = Matches selected pitch filter")
                        Text("• **Legend** at the bottom showing color meanings")
                    }
                }

                // Viewing Results
                HelpSection(title: "Viewing Results", icon: "chart.bar") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The Results tab shows statistics:")
                        Text("• **Team filter** - select which opponent team to view")
                        Text("• **Player filter** - view individual player stats")
                        Text("• **Hit type breakdown** - counts by type")
                        Text("• **Pitch patterns** - what pitches they hit well")
                        Text("• **Mini spray chart** - visual hit distribution")
                    }
                }

                // Managing Teams
                HelpSection(title: "Managing Teams", icon: "gear") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("In Settings, you can:")
                        Text("• **Switch opponent teams** - select from the team picker")
                        Text("• **Create new teams** - add more opponent teams to scout")
                        Text("• **Delete teams** - remove a team and all its data")
                        Text("• **Change team name** - tap to edit")
                        Text("• **Add players** - tap Add Player (only number required)")
                        Text("• **Reorder lineup** - drag players using the handle")
                        Text("• **Remove players** - swipe left to delete")
                        Text("• **Clear player hits** - remove one player's data")
                        Text("• **Clear all hits** - reset all hit data")
                        Text("• **Add your team logo** - appears in exports")
                    }
                }

                // Tips
                HelpSection(title: "Tips", icon: "lightbulb") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Track pitch info to see what pitches each batter handles best")
                        Text("• Tap pitch stats to highlight matching hits on the field")
                        Text("• Review spray charts before games to scout tendencies")
                        Text("• Use Dark Mode for visibility at evening games")
                        Text("• The lineup order matches their batting order - reorder as needed")
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
