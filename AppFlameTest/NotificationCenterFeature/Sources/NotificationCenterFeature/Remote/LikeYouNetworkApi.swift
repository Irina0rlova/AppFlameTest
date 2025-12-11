import Foundation

public class LikeYouNetworkApi: NetworkApi {
    public typealias T = [LikeItem]?
    
    public func fetchData(page: Int, batchSize: Int, completion: @Sendable @escaping (Result<[LikeItem]?, any Error>) -> Void) async {
        do {
            let res = try await generateLikeItems(page: page, batchSize: batchSize)
            completion(.success(res))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func generateLikeItems(page: Int, batchSize: Int) async throws -> [LikeItem] {
        var likeItems: [LikeItem] = []
        
        for i in ((page - 1) * batchSize)..<(page * batchSize) {
            let likeItem = LikeItem(
                id: UUID(),
                userName: "User \(i)",
                avatarURL: URL(string: "https://randomuser.me/api/portraits/men/\(i+1).jpg"),
                isBlurred: true
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
