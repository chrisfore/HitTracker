import SwiftUI
import PhotosUI

struct TeamSetupView: View {
    @EnvironmentObject var database: DatabaseManager
    @Binding var hasCompletedSetup: Bool

    @State private var showingTeamSetup = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var teamLogo: UIImage?
    @State private var showingRestoreAlert = false
    @State private var restoreMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // App Icon/Logo area
                Image(systemName: "figure.baseball")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.bottom, 8)

                Text("Welcome to HitTracker")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Track and analyze hitting patterns")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // Optional setup buttons
                VStack(spacing: 12) {
                    // Upload Team Logo
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: teamLogo != nil ? "checkmark.circle.fill" : "photo")
                                .foregroundColor(teamLogo != nil ? .green : .blue)
                            Text(teamLogo != nil ? "Logo Added" : "Upload Your Team Logo")
                            Spacer()
                            if teamLogo != nil {
                                Image(uiImage: teamLogo!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(4)
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)

                    // Setup First Team
                    Button {
                        showingTeamSetup = true
                    } label: {
                        HStack {
                            Image(systemName: "person.3")
                                .foregroundColor(.blue)
                            Text("Setup First Team")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)

                    // Restore Previous Purchase
                    Button {
                        restorePurchases()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                            Text("Restore Previous Purchase")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                Spacer()

                // Start Tracking Button
                Button {
                    startTracking()
                } label: {
                    Text("Start Tracking")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("HitTracker Setup")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTeamSetup) {
                TeamSetupSheet(onComplete: { teamName, players in
                    // Create the team
                    let team = database.addTeam(name: teamName)
                    database.selectTeam(team.id)

                    // Add players
                    for player in players {
                        database.addPlayer(teamId: team.id, name: player.name, number: player.number)
                    }
                })
            }
            .alert("Restore Purchases", isPresented: $showingRestoreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(restoreMessage)
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
        }
    }

    private func startTracking() {
        // Save logo if selected
        if let logo = teamLogo {
            database.saveLogo(logo)
        }
        hasCompletedSetup = true
    }

    private func restorePurchases() {
        // Placeholder for App Store restore functionality
        // In a real implementation, this would call StoreKit to restore purchases
        restoreMessage = "No previous purchases found to restore."
        showingRestoreAlert = true
    }
}

// MARK: - Team Setup Sheet

struct TeamSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onComplete: (String, [PlayerInput]) -> Void

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
        !teamName.isEmpty && players.contains { !$0.number.isEmpty }
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
                        onComplete(teamName, players.filter { !$0.number.isEmpty })
                        dismiss()
                    } label: {
                        Text("Save Team")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Setup Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }
}

#Preview {
    TeamSetupView(hasCompletedSetup: .constant(false))
        .environmentObject(DatabaseManager.shared)
}
