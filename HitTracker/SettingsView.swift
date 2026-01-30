import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var database: DatabaseManager
    @AppStorage("isDarkMode") private var isDarkMode = false

    @State private var showingAddPlayer = false
    @State private var showingEditTeamName = false
    @State private var showingClearPlayerHits = false
    @State private var showingClearAllHits = false
    @State private var showingRemoveLogoAlert = false

    @State private var newPlayerName = ""
    @State private var newPlayerNumber = ""
    @State private var editedTeamName = ""
    @State private var playerToClear: Player?

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var teamLogo: UIImage?

    var body: some View {
        NavigationStack {
            List {
                // Team Name Section
                Section("Team") {
                    Button {
                        editedTeamName = database.team.name
                        showingEditTeamName = true
                    } label: {
                        HStack {
                            Text("Team Name")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(database.team.name)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Lineup Section
                Section("Lineup") {
                    ForEach(database.team.sortedPlayers) { player in
                        HStack {
                            Text("#\(player.number)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 35, alignment: .leading)
                            Text(player.name)
                            Spacer()
                            Text("\(database.getHits(for: player.id).count) hits")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deletePlayer)
                    .onMove(perform: movePlayer)

                    Button {
                        showingAddPlayer = true
                    } label: {
                        Label("Add Player", systemImage: "plus.circle")
                    }
                }

                // Data Management Section
                Section("Data Management") {
                    if !database.team.players.isEmpty {
                        Menu {
                            ForEach(database.team.sortedPlayers) { player in
                                Button("\(player.name)") {
                                    playerToClear = player
                                    showingClearPlayerHits = true
                                }
                            }
                        } label: {
                            HStack {
                                Label("Clear Player Hits", systemImage: "person.crop.circle.badge.minus")
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Button(role: .destructive) {
                        showingClearAllHits = true
                    } label: {
                        Label("Clear All Hit Data", systemImage: "trash")
                    }
                }

                // Team Logo Section
                Section("Team Logo") {
                    if let logo = teamLogo {
                        HStack {
                            Image(uiImage: logo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)

                            Spacer()

                            Button(role: .destructive) {
                                showingRemoveLogoAlert = true
                            } label: {
                                Text("Remove")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(teamLogo == nil ? "Add Team Logo" : "Change Team Logo", systemImage: "photo")
                    }
                }

                // Help Section
                Section("Help") {
                    NavigationLink {
                        HelpView()
                    } label: {
                        Label("How to Use This App", systemImage: "questionmark.circle")
                    }
                }

                // Appearance Section
                Section("Appearance") {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                }

                // App Version Section
                Section {
                    HStack {
                        Spacer()
                        Text("Build \(AppVersion.displayVersion)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Settings")
            .toolbar {
                EditButton()
            }

            // Edit Team Name Alert
            .alert("Edit Team Name", isPresented: $showingEditTeamName) {
                TextField("Team Name", text: $editedTeamName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if !editedTeamName.isEmpty {
                        database.updateTeamName(editedTeamName)
                    }
                }
            }

            // Add Player Alert
            .alert("Add Player", isPresented: $showingAddPlayer) {
                TextField("Player Name", text: $newPlayerName)
                TextField("Number", text: $newPlayerNumber)
                Button("Cancel", role: .cancel) {
                    newPlayerName = ""
                    newPlayerNumber = ""
                }
                Button("Add") {
                    if !newPlayerName.isEmpty && !newPlayerNumber.isEmpty {
                        database.addPlayer(name: newPlayerName, number: newPlayerNumber)
                        newPlayerName = ""
                        newPlayerNumber = ""
                    }
                }
            }

            // Clear Player Hits Confirmation
            .alert("Clear Player Hits", isPresented: $showingClearPlayerHits) {
                Button("Cancel", role: .cancel) {
                    playerToClear = nil
                }
                Button("Clear", role: .destructive) {
                    if let player = playerToClear {
                        database.clearHits(for: player.id)
                    }
                    playerToClear = nil
                }
            } message: {
                if let player = playerToClear {
                    Text("Are you sure you want to clear all hit data for \(player.name)? This cannot be undone.")
                }
            }

            // Clear All Hits Confirmation
            .alert("Clear All Hit Data", isPresented: $showingClearAllHits) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    database.clearAllHits()
                }
            } message: {
                Text("Are you sure you want to clear ALL hit data for the entire team? This cannot be undone.")
            }

            // Remove Logo Confirmation
            .alert("Remove Logo", isPresented: $showingRemoveLogoAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    database.removeLogo()
                    teamLogo = nil
                    selectedPhotoItem = nil
                }
            } message: {
                Text("Are you sure you want to remove the team logo?")
            }

            .onChange(of: selectedPhotoItem) {
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        database.saveLogo(image)
                        teamLogo = image
                    }
                }
            }
            .onAppear {
                teamLogo = database.loadLogo()
            }
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        let players = database.team.sortedPlayers
        for index in offsets {
            database.removePlayer(players[index])
        }
    }

    private func movePlayer(from source: IndexSet, to destination: Int) {
        var players = database.team.sortedPlayers
        players.move(fromOffsets: source, toOffset: destination)
        database.reorderPlayers(players)
    }
}

#Preview {
    SettingsView()
        .environmentObject(DatabaseManager.shared)
}
