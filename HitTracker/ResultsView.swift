import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var database: DatabaseManager
    @State private var selectedPlayer: Player?
    @State private var selectedTeam: Team?

    var filteredPlayers: [Player] {
        if let team = selectedTeam {
            return database.getPlayers(for: team.id)
        }
        return database.players.sorted { $0.lineupOrder < $1.lineupOrder }
    }

    var body: some View {
        NavigationStack {
            List {
                // Team Filter
                Section {
                    Picker("Team", selection: $selectedTeam) {
                        Text("All Teams").tag(nil as Team?)
                        ForEach(database.opponentTeams) { team in
                            Text(team.name).tag(team as Team?)
                        }
                    }
                }

                // Player Filter
                Section {
                    Picker("Player", selection: $selectedPlayer) {
                        Text("All Players").tag(nil as Player?)
                        ForEach(filteredPlayers) { player in
                            Text(player.displayName).tag(player as Player?)
                        }
                    }
                }

                if let player = selectedPlayer {
                    // Individual player stats
                    PlayerStatsSection(player: player)
                } else {
                    // Team overview
                    TeamOverviewSection(selectedTeam: selectedTeam)
                }
            }
            .onChange(of: selectedTeam) {
                // Reset player selection when team changes
                selectedPlayer = nil
            }
        }
    }
}

// MARK: - Player Stats Section

struct PlayerStatsSection: View {
    let player: Player
    @EnvironmentObject var database: DatabaseManager

    var hits: [Hit] {
        database.getHits(forPlayer: player.id)
    }

    var hitTypeStats: [(HitType, Int)] {
        database.getHitTypeStats(for: player.id)
    }

    var pitchStats: [PitchStats] {
        database.getPitchStats(for: player.id)
    }

    var body: some View {
        Section("Summary - \(player.displayName)") {
            HStack {
                Text("Total Hits")
                Spacer()
                Text("\(hits.count)")
                    .fontWeight(.bold)
            }
        }

        Section("Hit Types") {
            ForEach(hitTypeStats, id: \.0) { hitType, count in
                HStack {
                    Circle()
                        .fill(hitColor(for: hitType))
                        .frame(width: 12, height: 12)
                    Text(hitType.rawValue)
                    Spacer()
                    Text("\(count)")
                        .foregroundColor(.secondary)
                }
            }
        }

        if !pitchStats.isEmpty {
            Section("Pitch Breakdown") {
                ForEach(pitchStats) { stat in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(stat.pitchType.rawValue)
                                .font(.subheadline)
                            Text(stat.pitchLocation.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(stat.count) hit\(stat.count == 1 ? "" : "s")")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }

        Section("Spray Chart") {
            HStack {
                Spacer()
                MiniSprayChart(hits: hits)
                    .frame(width: 200, height: 200)
                Spacer()
            }
            .padding(.vertical)
        }
    }

    func hitColor(for hitType: HitType) -> Color {
        switch hitType {
        case .flyBall: return .blue
        case .lineDrive: return .red
        case .popUp: return .purple
        case .grounder: return .orange
        }
    }
}

// MARK: - Team Overview Section

struct TeamOverviewSection: View {
    let selectedTeam: Team?
    @EnvironmentObject var database: DatabaseManager

    var totalHits: Int {
        if let team = selectedTeam {
            return database.getHits(forTeam: team.id).count
        }
        return database.hits.count
    }

    var playerHitCounts: [(Player, Int)] {
        let players: [Player]
        if let team = selectedTeam {
            players = database.getPlayers(for: team.id)
        } else {
            players = database.players.sorted { $0.lineupOrder < $1.lineupOrder }
        }
        return players.map { player in
            (player, database.getHits(forPlayer: player.id).count)
        }
    }

    var body: some View {
        Section("Team Summary") {
            HStack {
                Text("Total Hits")
                Spacer()
                Text("\(totalHits)")
                    .fontWeight(.bold)
            }
        }

        Section("Hits by Player") {
            ForEach(playerHitCounts, id: \.0.id) { player, count in
                HStack {
                    Text("#\(player.number)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .leading)
                    Text(player.name.isEmpty ? "(No name)" : player.name)
                        .foregroundColor(player.name.isEmpty ? .secondary : .primary)
                    Spacer()
                    Text("\(count)")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Mini Spray Chart

struct MiniSprayChart: View {
    let hits: [Hit]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Field outline
                SoftballFieldShape()
                    .fill(Color.green.opacity(0.2))
                    .overlay(
                        SoftballFieldShape()
                            .stroke(Color.green, lineWidth: 1)
                    )

                // Hit dots
                ForEach(hits) { hit in
                    Circle()
                        .fill(hitColor(for: hit.hitType))
                        .frame(width: 10, height: 10)
                        .position(
                            x: hit.locationX * geometry.size.width,
                            y: hit.locationY * geometry.size.height
                        )
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    func hitColor(for hitType: HitType) -> Color {
        switch hitType {
        case .flyBall: return .blue
        case .lineDrive: return .red
        case .popUp: return .purple
        case .grounder: return .orange
        }
    }
}

#Preview {
    ResultsView()
        .environmentObject(DatabaseManager.shared)
}
