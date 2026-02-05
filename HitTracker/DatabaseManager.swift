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
    private let logoKey = "teamLogoData"

    // Legacy keys for migration
    private let legacyTeamKey = "savedTeam"

    // iCloud Key-Value Store
    private let iCloudStore = NSUbiquitousKeyValueStore.default

    private init() {
        setupiCloudSync()
        loadData()
        migrateFromLegacyData()
        migrateLocalDataToiCloud()
    }

    // MARK: - iCloud Sync Setup

    private func setupiCloudSync() {
        // Listen for external changes from iCloud
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudDataDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloudStore
        )

        // Synchronize with iCloud
        iCloudStore.synchronize()
    }

    @objc private func iCloudDataDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonKey = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }

        // Handle different change reasons
        switch reasonKey {
        case NSUbiquitousKeyValueStoreServerChange,
             NSUbiquitousKeyValueStoreInitialSyncChange:
            // Data changed from another device or initial sync
            DispatchQueue.main.async {
                self.loadData()
            }
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            // Over quota - fall back to local storage only
            print("iCloud storage quota exceeded")
        case NSUbiquitousKeyValueStoreAccountChange:
            // Account changed - reload data
            DispatchQueue.main.async {
                self.loadData()
            }
        default:
            break
        }
    }

    // MARK: - Data Persistence (iCloud with local fallback)

    private func getData(forKey key: String) -> Data? {
        // Try iCloud first
        if let data = iCloudStore.data(forKey: key) {
            return data
        }
        // Fall back to local UserDefaults
        return UserDefaults.standard.data(forKey: key)
    }

    private func setData(_ data: Data?, forKey key: String) {
        // Save to both iCloud and local
        if let data = data {
            iCloudStore.set(data, forKey: key)
            UserDefaults.standard.set(data, forKey: key)
        } else {
            iCloudStore.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
        iCloudStore.synchronize()
    }

    private func getString(forKey key: String) -> String? {
        // Try iCloud first
        if let string = iCloudStore.string(forKey: key) {
            return string
        }
        // Fall back to local UserDefaults
        return UserDefaults.standard.string(forKey: key)
    }

    private func setString(_ string: String?, forKey key: String) {
        if let string = string {
            iCloudStore.set(string, forKey: key)
            UserDefaults.standard.set(string, forKey: key)
        } else {
            iCloudStore.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
        iCloudStore.synchronize()
    }

    func loadData() {
        // Load teams
        if let teamsData = getData(forKey: teamsKey),
           let savedTeams = try? JSONDecoder().decode([Team].self, from: teamsData) {
            opponentTeams = savedTeams
        }

        // Load players
        if let playersData = getData(forKey: playersKey),
           let savedPlayers = try? JSONDecoder().decode([Player].self, from: playersData) {
            players = savedPlayers
        }

        // Load hits
        if let hitsData = getData(forKey: hitsKey),
           let savedHits = try? JSONDecoder().decode([Hit].self, from: hitsData) {
            hits = savedHits
        }

        // Load selected team
        if let selectedTeamString = getString(forKey: selectedTeamKey),
           let teamId = UUID(uuidString: selectedTeamString) {
            selectedTeamId = teamId
        } else if let firstTeam = opponentTeams.first {
            selectedTeamId = firstTeam.id
        }
    }

    private func saveTeams() {
        if let encoded = try? JSONEncoder().encode(opponentTeams) {
            setData(encoded, forKey: teamsKey)
        }
    }

    private func savePlayers() {
        if let encoded = try? JSONEncoder().encode(players) {
            setData(encoded, forKey: playersKey)
        }
    }

    private func saveHits() {
        if let encoded = try? JSONEncoder().encode(hits) {
            setData(encoded, forKey: hitsKey)
        }
    }

    private func saveSelectedTeam() {
        setString(selectedTeamId?.uuidString, forKey: selectedTeamKey)
    }

    // Migrate existing local data to iCloud on first run
    private func migrateLocalDataToiCloud() {
        // Check if we have local data but no iCloud data
        let hasLocalTeams = UserDefaults.standard.data(forKey: teamsKey) != nil
        let hasiCloudTeams = iCloudStore.data(forKey: teamsKey) != nil

        if hasLocalTeams && !hasiCloudTeams {
            // Push local data to iCloud
            if let teamsData = UserDefaults.standard.data(forKey: teamsKey) {
                iCloudStore.set(teamsData, forKey: teamsKey)
            }
            if let playersData = UserDefaults.standard.data(forKey: playersKey) {
                iCloudStore.set(playersData, forKey: playersKey)
            }
            if let hitsData = UserDefaults.standard.data(forKey: hitsKey) {
                iCloudStore.set(hitsData, forKey: hitsKey)
            }
            if let selectedTeam = UserDefaults.standard.string(forKey: selectedTeamKey) {
                iCloudStore.set(selectedTeam, forKey: selectedTeamKey)
            }
            // Migrate logo if exists
            if let logoImage = loadLogoFromLocal() {
                saveLogo(logoImage)
            }
            iCloudStore.synchronize()
        }
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

    // MARK: - Team Logo (synced via iCloud)

    func saveLogo(_ image: UIImage) {
        // Save to local Documents directory
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let logoURL = documentsURL.appendingPathComponent("team_logo.png")

        if let pngData = image.pngData() {
            try? pngData.write(to: logoURL)

            // Also save to iCloud key-value store (compressed for size limits)
            // Resize image if needed to stay within iCloud limits
            let resizedImage = resizeImageForCloud(image, maxSize: 200)
            if let compressedData = resizedImage.jpegData(compressionQuality: 0.7) {
                iCloudStore.set(compressedData, forKey: logoKey)
                iCloudStore.synchronize()
            }
        }
    }

    private func resizeImageForCloud(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        if ratio >= 1.0 { return image }

        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func loadLogo() -> UIImage? {
        // Try local first (higher quality)
        if let localLogo = loadLogoFromLocal() {
            return localLogo
        }

        // Fall back to iCloud (lower quality but synced)
        if let cloudData = iCloudStore.data(forKey: logoKey),
           let cloudImage = UIImage(data: cloudData) {
            // Save to local for future use
            saveLogo(cloudImage)
            return cloudImage
        }

        return nil
    }

    private func loadLogoFromLocal() -> UIImage? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let logoURL = documentsURL.appendingPathComponent("team_logo.png")

        if FileManager.default.fileExists(atPath: logoURL.path) {
            return UIImage(contentsOfFile: logoURL.path)
        }
        return nil
    }

    func removeLogo() {
        // Remove from local
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let logoURL = documentsURL.appendingPathComponent("team_logo.png")
        try? FileManager.default.removeItem(at: logoURL)

        // Remove from iCloud
        iCloudStore.removeObject(forKey: logoKey)
        iCloudStore.synchronize()
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
