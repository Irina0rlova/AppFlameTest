import Foundation
protocol Repository {
    associatedtype T
    func load(page: Int, batchSize: Int) async throws
    func getData() -> T
    func getCursor() -> Int?
    func removeItem(id: UUID) async
}

public class LikeYouRepository<Api: NetworkApi & Sendable, Store: LocalApi & Sendable>: Repository where Api.T == LikeItem, Store.T == [LikeItem]? {
    typealias T = [LikeItem]?
    
    private let api: Api
    private let localApi: Store
    
    private var cursor: Int? = 1
    
    public init(
        api: Api,
        localApi: Store
    ) {
        self.api = api
        self.localApi = localApi
    }

    public func load(page: Int, batchSize: Int) async throws {
        let api = self.api
        let localApi = self.localApi
        
        guard cursor != nil else {
            return
        }

        if page == 1 {
            localApi.clear()
        }
        
        let likeItems = try await api.fetchData(page: page, batchSize: batchSize)
        localApi.createOrUpdate(data: (likeItems.items))
        self.cursor = likeItems.nextCursor
    }
    
    public func getData() -> [LikeItem]? {
        localApi.get()
    }
    
    public func getCursor() -> Int? {
        cursor
    }
    
    public func removeItem(id: UUID) async {
        var items = localApi.get()
        items?.removeAll(where: { $0.id == id })
        
        await api.removeItem(id: id)
        
        localApi.clear()
        localApi.createOrUpdate(data: (items))
    }
}

// LikeYouRepository is Sendable because its generic members are Sendable.
// Marked as @unchecked because we cannot statically guarantee thread safety.
extension LikeYouRepository: @unchecked Sendable {}

