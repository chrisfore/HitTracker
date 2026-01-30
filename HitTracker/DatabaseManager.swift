import Foundation
import SwiftUI

class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()

    @Published var team: Team = Team()
    @Published var hits: [Hit] = []

    private let teamKey = "savedTeam"
    private let hitsKey = "savedHits"

    private init() {
        loadData()
    }

    // MARK: - Data Persistence

    func loadData() {
        // Load team
        if let teamData = UserDefaults.standard.data(forKey: teamKey),
           let savedTeam = try? JSONDecoder().decode(Team.self, from: teamData) {
            team = savedTeam
        }

        // Load hits
        if let hitsData = UserDefaults.standard.data(forKey: hitsKey),
           let savedHits = try? JSONDecoder().decode([Hit].self, from: hitsData) {
            hits = savedHits
        }
    }

    private func saveTeam() {
        if let encoded = try? JSONEncoder().encode(team) {
            UserDefaults.standard.set(encoded, forKey: teamKey)
        }
    }

    private func saveHits() {
        if let encoded = try? JSONEncoder().encode(hits) {
            UserDefaults.standard.set(encoded, forKey: hitsKey)
        }
    }

    // MARK: - Team Operations

    func updateTeamName(_ name: String) {
        team.name = name
        saveTeam()
    }

    func addPlayer(name: String, number: String) {
        let lineupOrder = (team.players.map { $0.lineupOrder }.max() ?? 0) + 1
        let player = Player(name: name, number: number, lineupOrder: lineupOrder)
        team.players.append(player)
        saveTeam()
    }

    func updatePlayer(_ player: Player) {
        if let index = team.players.firstIndex(where: { $0.id == player.id }) {
            team.players[index] = player
            saveTeam()
        }
    }

    func removePlayer(_ player: Player) {
        team.players.removeAll { $0.id == player.id }
        // Also remove hits for this player
        hits.removeAll { $0.playerId == player.id }
        saveTeam()
        saveHits()
    }

    func reorderPlayers(_ players: [Player]) {
        var updatedPlayers = players
        for i in 0..<updatedPlayers.count {
            updatedPlayers[i].lineupOrder = i + 1
        }
        team.players = updatedPlayers
        saveTeam()
    }

    // MARK: - Hit Operations

    func addHit(playerId: UUID, locationX: Double, locationY: Double, hitType: HitType, pitchType: PitchType?, pitchLocation: PitchLocation?) {
        let hit = Hit(
            playerId: playerId,
            locationX: locationX,
            locationY: locationY,
            hitType: hitType,
            pitchType: pitchType,
            pitchLocation: pitchLocation
        )
        hits.append(hit)
        saveHits()
    }

    func getHits(for playerId: UUID) -> [Hit] {
        return hits.filter { $0.playerId == playerId }
    }

    func clearHits(for playerId: UUID) {
        hits.removeAll { $0.playerId == playerId }
        saveHits()
    }

    func clearAllHits() {
        hits.removeAll()
        saveHits()
    }

    // MARK: - Statistics

    func getPitchStats(for playerId: UUID) -> [PitchStats] {
        let playerHits = getHits(for: playerId)

        // Group by pitch type and location
        var statsDict: [String: Int] = [:]

        for hit in playerHits {
            if let pitchType = hit.pitchType, let pitchLocation = hit.pitchLocation {
                let key = "\(pitchType.rawValue)|\(pitchLocation.rawValue)"
                statsDict[key, default: 0] += 1
            }
        }

        // Convert to PitchStats array
        var stats: [PitchStats] = []
        for (key, count) in statsDict {
            let components = key.split(separator: "|")
            if components.count == 2,
               let pitchType = PitchType(rawValue: String(components[0])),
               let pitchLocation = PitchLocation(rawValue: String(components[1])) {
                stats.append(PitchStats(pitchType: pitchType, pitchLocation: pitchLocation, count: count))
            }
        }

        return stats.sorted { $0.count > $1.count }
    }

    func getHitTypeStats(for playerId: UUID) -> [(HitType, Int)] {
        let playerHits = getHits(for: playerId)
        var stats: [HitType: Int] = [:]

        for hit in playerHits {
            stats[hit.hitType, default: 0] += 1
        }

        return HitType.allCases.map { ($0, stats[$0] ?? 0) }
    }

    // MARK: - Team Logo

    func saveLogo(_ image: UIImage) {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let logoURL = documentsURL.appendingPathComponent("team_logo.png")

        if let pngData = image.pngData() {
            try? pngData.write(to: logoURL)
        }
    }

    func loadLogo() -> UIImage? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let logoURL = documentsURL.appendingPathComponent("team_logo.png")

        if FileManager.default.fileExists(atPath: logoURL.path) {
            return UIImage(contentsOfFile: logoURL.path)
        }
        return nil
    }

    func removeLogo() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let logoURL = documentsURL.appendingPathComponent("team_logo.png")
        try? FileManager.default.removeItem(at: logoURL)
    }

    // MARK: - Setup Check

    var hasTeamSetup: Bool {
        return !team.name.isEmpty && !team.players.isEmpty
    }
}
