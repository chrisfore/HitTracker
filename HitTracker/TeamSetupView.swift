import SwiftUI

struct TeamSetupView: View {
    @EnvironmentObject var database: DatabaseManager
    @Binding var hasCompletedSetup: Bool

    @State private var teamName = ""
    @State private var players: [PlayerInput] = [
        PlayerInput(name: "", number: "")
    ]

    struct PlayerInput: Identifiable {
        let id = UUID()
        var name: String
        var number: String
    }

    var isValid: Bool {
        // Only require team name and at least one player with a number
        !teamName.isEmpty && players.contains { !$0.number.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Opponent Team Information") {
                    TextField("Opponent Team Name", text: $teamName)
                }

                Section("Opponent Lineup") {
                    ForEach($players) { $player in
                        HStack {
                            TextField("Number", text: $player.number)
                                .keyboardType(.numberPad)
                                .frame(width: 60)

                            TextField("Name (Optional)", text: $player.name)
                        }
                    }
                    .onDelete(perform: deletePlayer)

                    Button {
                        players.append(PlayerInput(name: "", number: ""))
                    } label: {
                        Label("Add Player", systemImage: "plus.circle")
                    }
                }

                Section {
                    Button {
                        saveAndContinue()
                    } label: {
                        Text("Start Tracking")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Scout Setup")
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }

    private func saveAndContinue() {
        // Create the opponent team
        let team = database.addTeam(name: teamName)
        database.selectTeam(team.id)

        // Only add players with numbers (name is optional now)
        let validPlayers = players.filter { !$0.number.isEmpty }
        for player in validPlayers {
            database.addPlayer(teamId: team.id, name: player.name, number: player.number)
        }

        hasCompletedSetup = true
    }
}

#Preview {
    TeamSetupView(hasCompletedSetup: .constant(false))
        .environmentObject(DatabaseManager.shared)
}
