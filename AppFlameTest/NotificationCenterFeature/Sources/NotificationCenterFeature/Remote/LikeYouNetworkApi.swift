import Foundation

public class LikeYouNetworkApi: NetworkApi {
    public typealias T = [LikeItem]?
    
    public func fetchData(page: Int, batchSize: Int) async throws -> [LikeItem]? {
        do {
            let res = try await generateLikeItems(page: page, batchSize: batchSize)
            return res
        } catch {
            throw error
        }
    }
    
    private func generateLikeItems(page: Int, batchSize: Int) async throws -> [LikeItem] {
        var likeItems: [LikeItem] = []
        
        for i in ((page - 1) * batchSize)..<(page * batchSize) {
            let likeItem = LikeItem(
                id: UUID(),
                userName: "User \(i)",
                avatarURL: URL(string: "https://randomuser.me/api/portraits/men/\(i+1).jpg"),
                isBlurred: false
            )
            likeItems.append(likeItem)
        }
        
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
        
        return likeItems
    }
}

// LikeYouNetworkApi has no shared mutable state; mark as @unchecked Sendable
// to satisfy the repository's generic Sendable constraints.
extension LikeYouNetworkApi: @unchecked Sendable {}
