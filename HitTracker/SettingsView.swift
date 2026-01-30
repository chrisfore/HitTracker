import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var database: DatabaseManager
    @AppStorage("isDarkMode") private var isDarkMode = false

    @State private var showingAddTeam = false
    @State private var showingEditTeamName = false
    @State private var showingDeleteTeam = false
    @State private var showingAddPlayer = false
    @State private var showingClearPlayerHits = false
    @State private var showingClearAllHits = false
    @State private var showingRemoveLogoAlert = false

    @State private var newTeamName = ""
    @State private var editedTeamName = ""
    @State private var newPlayerName = ""
    @State private var newPlayerNumber = ""
    @State private var playerToClear: Player?
    @State private var selectedTeamForManagement: Team?

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var teamLogo: UIImage?

    var body: some View {
        NavigationStack {
            List {
                // Opponent Team Selection Section
                Section("Opponent Team") {
                    Picker("Select Team", selection: $selectedTeamForManagement) {
                        Text("Select a team...").tag(nil as Team?)
                        ForEach(database.opponentTeams) { team in
                            Text(team.name).tag(team as Team?)
                        }
                    }

                    Button {
                        newTeamName = ""
                        showingAddTeam = true
                    } label: {
                        Label("Create New Team", systemImage: "plus.circle")
                    }

                    if let team = selectedTeamForManagement {
                        Button {
                            editedTeamName = team.name
                            showingEditTeamName = true
                        } label: {
                            HStack {
                                Text("Team Name")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(team.name)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Button(role: .destructive) {
                            showingDeleteTeam = true
                        } label: {
                            Label("Delete This Team", systemImage: "trash")
                        }
                    }
                }

                // Lineup Section (filtered by selected team)
                if let team = selectedTeamForManagement {
                    Section("Lineup - \(team.name)") {
                        let teamPlayers = database.getPlayers(for: team.id)
                        ForEach(teamPlayers) { player in
                            HStack {
                                Text("#\(player.number)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 35, alignment: .leading)
                                Text(player.name.isEmpty ? "(No name)" : player.name)
                                    .foregroundColor(player.name.isEmpty ? .secondary : .primary)
                                Spacer()
                                Text("\(database.getHits(forPlayer: player.id).count) hits")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete { offsets in deletePlayer(at: offsets, from: team) }
                        .onMove { source, dest in movePlayer(from: source, to: dest, in: team) }

                        Button {
                            newPlayerName = ""
                            newPlayerNumber = ""
                            showingAddPlayer = true
                        } label: {
                            Label("Add Player", systemImage: "plus.circle")
                        }
                    }
                }

                // Data Management Section
                Section("Data Management") {
                    if let team = selectedTeamForManagement {
                        let teamPlayers = database.getPlayers(for: team.id)
                        if !teamPlayers.isEmpty {
                            Menu {
                                ForEach(teamPlayers) { player in
                                    Button(player.displayName) {
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
                    }

                    Button(role: .destructive) {
                        showingClearAllHits = true
                    } label: {
                        Label("Clear All Hit Data", systemImage: "trash")
                    }
                }

                // Your Team Logo Section
                Section("Your Team Logo") {
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
                        Label(teamLogo == nil ? "Add Your Team Logo" : "Change Your Team Logo", systemImage: "photo")
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

            // Add Team Alert
            .alert("Create New Team", isPresented: $showingAddTeam) {
                TextField("Team Name", text: $newTeamName)
                Button("Cancel", role: .cancel) {
                    newTeamName = ""
                }
                Button("Create") {
                    if !newTeamName.isEmpty {
                        let team = database.addTeam(name: newTeamName)
                        selectedTeamForManagement = team
                        database.selectTeam(team.id)
                        newTeamName = ""
                    }
                }
            }

            // Edit Team Name Alert
            .alert("Edit Team Name", isPresented: $showingEditTeamName) {
                TextField("Team Name", text: $editedTeamName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if !editedTeamName.isEmpty, let team = selectedTeamForManagement {
                        database.updateTeamName(editedTeamName, for: team.id)
                        // Update local reference
                        if let updatedTeam = database.opponentTeams.first(where: { $0.id == team.id }) {
                            selectedTeamForManagement = updatedTeam
                        }
                    }
                }
            }

            // Delete Team Confirmation
            .alert("Delete Team", isPresented: $showingDeleteTeam) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let team = selectedTeamForManagement {
                        database.removeTeam(team)
                        selectedTeamForManagement = database.opponentTeams.first
                    }
                }
            } message: {
                if let team = selectedTeamForManagement {
                    Text("Are you sure you want to delete \(team.name)? This will also delete all players and hit data for this team. This cannot be undone.")
                }
            }

            // Add Player Alert
            .alert("Add Player", isPresented: $showingAddPlayer) {
                TextField("Name (Optional)", text: $newPlayerName)
                TextField("Number", text: $newPlayerNumber)
                    .keyboardType(.numberPad)
                Button("Cancel", role: .cancel) {
                    newPlayerName = ""
                    newPlayerNumber = ""
                }
                Button("Add") {
                    if !newPlayerNumber.isEmpty, let team = selectedTeamForManagement {
                        database.addPlayer(teamId: team.id, name: newPlayerName, number: newPlayerNumber)
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
                        database.clearHits(forPlayer: player.id)
                    }
                    playerToClear = nil
                }
            } message: {
                if let player = playerToClear {
                    Text("Are you sure you want to clear all hit data for \(player.displayName)? This cannot be undone.")
                }
            }

            // Clear All Hits Confirmation
            .alert("Clear All Hit Data", isPresented: $showingClearAllHits) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    database.clearAllHits()
                }
            } message: {
                Text("Are you sure you want to clear ALL hit data for all teams? This cannot be undone.")
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
                Text("Are you sure you want to remove your team logo?")
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
                // Default to first team if none selected
                if selectedTeamForManagement == nil {
                    selectedTeamForManagement = database.opponentTeams.first
                }
            }
        }
    }

    private func deletePlayer(at offsets: IndexSet, from team: Team) {
        let teamPlayers = database.getPlayers(for: team.id)
        for index in offsets {
            database.removePlayer(teamPlayers[index])
        }
    }

    private func movePlayer(from source: IndexSet, to destination: Int, in team: Team) {
        var teamPlayers = database.getPlayers(for: team.id)
        teamPlayers.move(fromOffsets: source, toOffset: destination)
        database.reorderPlayers(teamPlayers, for: team.id)
    }
}

#Preview {
    SettingsView()
        .environmentObject(DatabaseManager.shared)
}
