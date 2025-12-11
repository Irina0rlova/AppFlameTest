import Foundation

public struct LikeItem: Identifiable, Equatable, Hashable, Codable, Sendable {
    public let id: UUID
    public var userName: String
    public var avatarURL: URL?
    public var isBlurred: Bool

    public init(
        id: UUID = UUID(),
        userName: String,
        avatarURL: URL? = nil,
        isBlurred: Bool = true
    ) {
        self.id = id
        self.userName = userName
        self.avatarURL = avatarURL
        self.isBlurred = isBlurred
    }
}

public extension LikeItem {
    static func mock(
        id: UUID = UUID(),
        name: String = "User",
        blurred: Bool = false
    ) -> LikeItem {
        LikeItem(id: id, userName: name, avatarURL: nil, isBlurred: blurred)
    }
}
