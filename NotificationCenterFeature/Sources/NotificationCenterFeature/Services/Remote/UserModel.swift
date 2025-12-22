import Foundation

public struct UserModel: Identifiable, Equatable, Hashable, Codable, Sendable {
    public let id: UUID
    public let userName: String
    public let avatarURL: String?
    
    public init(
        id: UUID = UUID(),
        userName: String,
        avatarURL: String? = nil
    ) {
        self.id = id
        self.userName = userName
        self.avatarURL = avatarURL
    }
}
