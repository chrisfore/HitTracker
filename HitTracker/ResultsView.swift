import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var database: DatabaseManager
    @State private var selectedPlayer: Player?

    var sortedPlayers: [Player] {
        database.team.sortedPlayers
    }

    var body: some View {
        NavigationStack {
            List {
                // Player Filter
                Section {
                    Picker("Player", selection: $selectedPlayer) {
                        Text("All Players").tag(nil as Player?)
                        ForEach(sortedPlayers) { player in
                            Text("#\(player.number) \(player.name)").tag(player as Player?)
                        }
                    }
                }

                if let player = selectedPlayer {
                    // Individual player stats
                    PlayerStatsSection(player: player)
                } else {
                    // Team overview
                    TeamOverviewSection()
                }
            }
            .navigationTitle("Results")
        }
    }
}

// MARK: - Player Stats Section

struct PlayerStatsSection: View {
    let player: Player
    @EnvironmentObject var database: DatabaseManager

    var hits: [Hit] {
        database.getHits(for: player.id)
    }

    var hitTypeStats: [(HitType, Int)] {
        database.getHitTypeStats(for: player.id)
    }

    var pitchStats: [PitchStats] {
        database.getPitchStats(for: player.id)
    }

    var body: some View {
        Section("Summary - \(player.name)") {
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
            MiniSprayChart(hits: hits)
                .frame(height: 200)
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
    @EnvironmentObject var database: DatabaseManager

    var totalHits: Int {
        database.hits.count
    }

    var playerHitCounts: [(Player, Int)] {
        database.team.sortedPlayers.map { player in
            (player, database.getHits(for: player.id).count)
        }
    }

    var body: some View {
        Section("Team Summary") {
            HStack {
                Text("Total Team Hits")
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
                    Text(player.name)
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
