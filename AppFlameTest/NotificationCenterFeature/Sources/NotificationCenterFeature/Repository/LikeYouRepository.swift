import Foundation
protocol Repository {
    associatedtype T
    func load(page: Int, batchSize: Int) async throws
    func getData() -> T
    func getCursor() -> Int?
    func removeItem(id: UUID) async
}

protocol LikeYouRepositoryProtocol {
    func updateBluredState(isBlured: Bool)
    func addNewItem(_ item: LikeItem) -> Bool
}

public class LikeYouRepository<Api: NetworkApi & Sendable, Store: LocalApi & Sendable>: LikeYouRepositoryProtocol, Repository where Store.T == [LikeItem]? {
    typealias T = [LikeItem]?
    
    private let api: Api
    private let localApi: Store
    private let mapper: LikedYouMapper
    
    private var cursor: Int? = 1
    
    public init(
        api: Api,
        localApi: Store
    ) {
        self.api = api
        self.localApi = localApi
        mapper = LikedYouMapper()
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
        
        let result = try await api.fetchData(page: page, batchSize: batchSize)
        let likeItems = Page(items: mapper.map(result.data), nextCursor: result.nextCursor)
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
    
    func updateBluredState(isBlured: Bool) {
        var items = localApi.get() ?? []
        items.indices.forEach {
            items[$0].isBlurred = isBlured
        }
        
        localApi.clear()
        localApi.createOrUpdate(data: items)
    }
    
    public func addNewItem(_ item: LikeItem) -> Bool {
        var items = localApi.get() ?? []
        if !items.contains(where: { $0.id == item.id }) {
            items.insert(item, at: 0)
            localApi.clear()
            localApi.createOrUpdate(data: items)
            
            return true
        }
        
        return false
    }
}

// LikeYouRepository is Sendable because its generic members are Sendable.
// Marked as @unchecked because we cannot statically guarantee thread safety.
extension LikeYouRepository: @unchecked Sendable {}
