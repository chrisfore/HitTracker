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
        !teamName.isEmpty && players.contains { !$0.name.isEmpty && !$0.number.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Team Information") {
                    TextField("Team Name", text: $teamName)
                }

                Section("Lineup") {
                    ForEach($players) { $player in
                        HStack {
                            TextField("Number", text: $player.number)
                                .keyboardType(.numberPad)
                                .frame(width: 60)

                            TextField("Player Name", text: $player.name)
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
            .navigationTitle("Team Setup")
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }

    private func saveAndContinue() {
        database.updateTeamName(teamName)

        let validPlayers = players.filter { !$0.name.isEmpty && !$0.number.isEmpty }
        for (index, player) in validPlayers.enumerated() {
            database.addPlayer(name: player.name, number: player.number)
        }

        hasCompletedSetup = true
    }
}

#Preview {
    TeamSetupView(hasCompletedSetup: .constant(false))
        .environmentObject(DatabaseManager.shared)
}
