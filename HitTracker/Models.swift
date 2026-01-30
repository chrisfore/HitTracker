import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    let teamId: UUID
    var name: String
    var number: String
    var lineupOrder: Int

    init(id: UUID = UUID(), teamId: UUID, name: String = "", number: String, lineupOrder: Int) {
        self.id = id
        self.teamId = teamId
        self.name = name
        self.number = number
        self.lineupOrder = lineupOrder
    }

    var displayName: String {
        if name.isEmpty {
            return "#\(number)"
        }
        return "#\(number) \(name)"
    }
}

struct Hit: Identifiable, Codable {
    let id: UUID
    let playerId: UUID
    let teamId: UUID
    let locationX: Double  // 0.0 to 1.0 relative to field width
    let locationY: Double  // 0.0 to 1.0 relative to field height
    let hitType: HitType
    let pitchType: PitchType?
    let pitchLocation: PitchLocation?
    let timestamp: Date

    init(id: UUID = UUID(), playerId: UUID, teamId: UUID, locationX: Double, locationY: Double, hitType: HitType, pitchType: PitchType? = nil, pitchLocation: PitchLocation? = nil, timestamp: Date = Date()) {
        self.id = id
        self.playerId = playerId
        self.teamId = teamId
        self.locationX = locationX
        self.locationY = locationY
        self.hitType = hitType
        self.pitchType = pitchType
        self.pitchLocation = pitchLocation
        self.timestamp = timestamp
    }
}

enum HitType: String, CaseIterable, Codable {
    case flyBall = "Fly Ball"
    case lineDrive = "Line Drive"
    case popUp = "Pop Up"
    case grounder = "Grounder"
}

enum PitchType: String, CaseIterable, Codable {
    case fastball = "Fastball"
    case changeUp = "Change Up"
    case curve = "Curve"
    case rise = "Rise"
    case drop = "Drop"
}

enum PitchLocation: String, CaseIterable, Codable {
    case high = "High"
    case low = "Low"
    case inside = "Inside"
    case outside = "Outside"
    case middle = "Middle"
}

struct Team: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String = "") {
        self.id = id
        self.name = name
    }
}

struct PitchStats: Identifiable, Equatable {
    let id = UUID()
    let pitchType: PitchType
    let pitchLocation: PitchLocation
    let count: Int

    static func == (lhs: PitchStats, rhs: PitchStats) -> Bool {
        lhs.pitchType == rhs.pitchType && lhs.pitchLocation == rhs.pitchLocation
    }
}

// Legacy structures for migration
struct LegacyTeam: Codable {
    var name: String
    var players: [LegacyPlayer]

    init(name: String = "", players: [LegacyPlayer] = []) {
        self.name = name
        self.players = players
    }
}

struct LegacyPlayer: Codable {
    let id: UUID
    var name: String
    var number: String
    var lineupOrder: Int
}

struct LegacyHit: Codable {
    let id: UUID
    let playerId: UUID
    let locationX: Double
    let locationY: Double
    let hitType: HitType
    let pitchType: PitchType?
    let pitchLocation: PitchLocation?
    let timestamp: Date
}
