import Foundation

struct AppVersion {
    static let version = "1"
    static let build = "5"

    static var displayVersion: String {
        return "\(version).\(build)"
    }
}
