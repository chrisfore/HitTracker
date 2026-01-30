import Foundation
import SwiftUI

class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()

    @Published var opponentTeams: [Team] = []
    @Published var players: [Player] = []
    @Published var hits: [Hit] = []
    @Published var selectedTeamId: UUID?

    private let teamsKey = "savedOpponentTeams"
    private let playersKey = "savedPlayers"
    private let hitsKey = "savedHits"
    private let selectedTeamKey = "selectedTeamId"

    // Legacy keys for migration
    private let legacyTeamKey = "savedTeam"

    private init() {
        loadData()
        migrateFromLegacyData()
    }

    // MARK: - Data Persistence

    func loadData() {
        // Load teams
        if let teamsData = UserDefaults.standard.data(forKey: teamsKey),
           let savedTeams = try? JSONDecoder().decode([Team].self, from: teamsData) {
            opponentTeams = savedTeams
        }

        // Load players
        if let playersData = UserDefaults.standard.data(forKey: playersKey),
           let savedPlayers = try? JSONDecoder().decode([Player].self, from: playersData) {
            players = savedPlayers
        }

        // Load hits
        if let hitsData = UserDefaults.standard.data(forKey: hitsKey),
           let savedHits = try? JSONDecoder().decode([Hit].self, from: hitsData) {
            hits = savedHits
        }

        // Load selected team
        if let selectedTeamString = UserDefaults.standard.string(forKey: selectedTeamKey),
           let teamId = UUID(uuidString: selectedTeamString) {
            selectedTeamId = teamId
        } else if let firstTeam = opponentTeams.first {
            selectedTeamId = firstTeam.id
        }
    }

    private func saveTeams() {
        if let encoded = try? JSONEncoder().encode(opponentTeams) {
            UserDefaults.standard.set(encoded, forKey: teamsKey)
        }
    }

    private func savePlayers() {
        if let encoded = try? JSONEncoder().encode(players) {
            UserDefaults.standard.set(encoded, forKey: playersKey)
        }
    }

    private func saveHits() {
        if let encoded = try? JSONEncoder().encode(hits) {
            UserDefaults.standard.set(encoded, forKey: hitsKey)
        }
    }

    private func saveSelectedTeam() {
        UserDefaults.standard.set(selectedTeamId?.uuidString, forKey: selectedTeamKey)
    }

    // MARK: - Team Operations

    var selectedTeam: Team? {
        guard let id = selectedTeamId else { return nil }
        return opponentTeams.first { $0.id == id }
    }

    @discardableResult
    func addTeam(name: String) -> Team {
        let team = Team(name: name)
        opponentTeams.append(team)
        saveTeams()
        return team
    }

    func updateTeamName(_ name: String, for teamId: UUID) {
        if let index = opponentTeams.firstIndex(where: { $0.id == teamId }) {
            opponentTeams[index].name = name
            saveTeams()
        }
    }

    func selectTeam(_ teamId: UUID?) {
        selectedTeamId = teamId
        saveSelectedTeam()
    }

    func removeTeam(_ team: Team) {
        // Remove all players for this team
        players.removeAll { $0.teamId == team.id }
        // Remove all hits for this team
        hits.removeAll { $0.teamId == team.id }
        // Remove the team
        opponentTeams.removeAll { $0.id == team.id }

        // Clear selection if this team was selected
        if selectedTeamId == team.id {
            selectedTeamId = opponentTeams.first?.id
        }

        saveTeams()
        savePlayers()
        saveHits()
        saveSelectedTeam()
    }

    // MARK: - Player Operations

    func getPlayers(for teamId: UUID) -> [Player] {
        return players.filter { $0.teamId == teamId }
            .sorted { $0.lineupOrder < $1.lineupOrder }
    }

    func addPlayer(teamId: UUID, name: String, number: String) {
        let existingPlayers = getPlayers(for: teamId)
        let lineupOrder = (existingPlayers.map { $0.lineupOrder }.max() ?? 0) + 1
        let player = Player(teamId: teamId, name: name, number: number, lineupOrder: lineupOrder)
        players.append(player)
        savePlayers()
    }

    func updatePlayer(_ player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
            savePlayers()
        }
    }

    func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
        // Also remove hits for this player
        hits.removeAll { $0.playerId == player.id }
        savePlayers()
        saveHits()
    }

    func reorderPlayers(_ reorderedPlayers: [Player], for teamId: UUID) {
        // Update lineup order for the reordered players
        for (index, player) in reorderedPlayers.enumerated() {
            if let playerIndex = players.firstIndex(where: { $0.id == player.id }) {
                players[playerIndex].lineupOrder = index + 1
            }
        }
        savePlayers()
    }

    // MARK: - Hit Operations

    func addHit(playerId: UUID, teamId: UUID, locationX: Double, locationY: Double, hitType: HitType, pitchType: PitchType?, pitchLocation: PitchLocation?) {
        let hit = Hit(
            playerId: playerId,
            teamId: teamId,
            locationX: locationX,
            locationY: locationY,
            hitType: hitType,
            pitchType: pitchType,
            pitchLocation: pitchLocation
        )
        hits.append(hit)
        saveHits()
    }

    func getHits(forPlayer playerId: UUID) -> [Hit] {
        return hits.filter { $0.playerId == playerId }
    }

    func getHits(forTeam teamId: UUID) -> [Hit] {
        return hits.filter { $0.teamId == teamId }
    }

    func clearHits(forPlayer playerId: UUID) {
        hits.removeAll { $0.playerId == playerId }
        saveHits()
    }

    func clearHits(forTeam teamId: UUID) {
        hits.removeAll { $0.teamId == teamId }
        saveHits()
    }

    func clearAllHits() {
        hits.removeAll()
        saveHits()
    }

    // MARK: - Statistics

    func getPitchStats(for playerId: UUID) -> [PitchStats] {
        let playerHits = getHits(forPlayer: playerId)

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
        let playerHits = getHits(forPlayer: playerId)
        var stats: [HitType: Int] = [:]

        for hit in playerHits {
            stats[hit.hitType, default: 0] += 1
        }

        return HitType.allCases.map { ($0, stats[$0] ?? 0) }
    }

    // MARK: - Team Logo (for user's team)

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
        return !opponentTeams.isEmpty
    }

    // MARK: - Migration

    private func migrateFromLegacyData() {
        // Check if legacy data exists and new data is empty
        guard opponentTeams.isEmpty,
              let legacyTeamData = UserDefaults.standard.data(forKey: legacyTeamKey),
              let legacyTeam = try? JSONDecoder().decode(LegacyTeam.self, from: legacyTeamData) else {
            return
        }

        // Create new team from legacy
        let newTeam = Team(name: legacyTeam.name)
        opponentTeams.append(newTeam)

        // Migrate players with new teamId
        for legacyPlayer in legacyTeam.players {
            let newPlayer = Player(
                id: legacyPlayer.id,
                teamId: newTeam.id,
                name: legacyPlayer.name,
                number: legacyPlayer.number,
                lineupOrder: legacyPlayer.lineupOrder
            )
            players.append(newPlayer)
        }

        // Migrate hits with new teamId
        if let legacyHitsData = UserDefaults.standard.data(forKey: hitsKey),
           let legacyHits = try? JSONDecoder().decode([LegacyHit].self, from: legacyHitsData) {
            hits.removeAll()
            for legacyHit in legacyHits {
                let newHit = Hit(
                    id: legacyHit.id,
                    playerId: legacyHit.playerId,
                    teamId: newTeam.id,
                    locationX: legacyHit.locationX,
                    locationY: legacyHit.locationY,
                    hitType: legacyHit.hitType,
                    pitchType: legacyHit.pitchType,
                    pitchLocation: legacyHit.pitchLocation,
                    timestamp: legacyHit.timestamp
                )
                hits.append(newHit)
            }
        }

        selectedTeamId = newTeam.id

        // Save migrated data
        saveTeams()
        savePlayers()
        saveHits()
        saveSelectedTeam()

        // Clear legacy data
        UserDefaults.standard.removeObject(forKey: legacyTeamKey)
    }
}
