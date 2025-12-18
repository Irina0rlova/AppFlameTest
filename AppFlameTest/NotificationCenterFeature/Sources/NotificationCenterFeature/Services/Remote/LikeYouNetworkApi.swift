import Foundation

public class LikeYouNetworkApi: NetworkApi {
    public func fetchData(page: Int, batchSize: Int) async throws -> (data: [UserModel]?, nextCursor: Int?) {
        do {
            let res = try await generateLikeItems(page: page, batchSize: batchSize)
            let nextCursor = page < 5 ? (page + 1) : nil
            return (data: res, nextCursor: nextCursor)
        } catch {
            throw error
        }
    }
    
    public func removeItem(id: UUID) async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {
            // handle error if needed
        }
    }
    
    private func generateLikeItems(page: Int, batchSize: Int) async throws -> [UserModel] {
        var users: [UserModel] = []
        
        for i in ((page - 1) * batchSize)..<(page * batchSize) {
            let likeItem = UserModel(
                id: UUID(),
                userName: "User \(i)",
                avatarURL: "https://randomuser.me/api/portraits/men/\(i+1).jpg",
            )
            users.append(likeItem)
        }
        
        try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
        return users
    }
}

// LikeYouNetworkApi has no shared mutable state; mark as @unchecked Sendable
// to satisfy the repository's generic Sendable constraints.
extension LikeYouNetworkApi: @unchecked Sendable {}
