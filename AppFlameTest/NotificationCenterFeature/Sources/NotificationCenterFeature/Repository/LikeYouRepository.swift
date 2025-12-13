protocol Repository {
    associatedtype T
    func load(page: Int, batchSize: Int) async throws
    func getData() async -> T
    func getCursor() -> Int?
}

public class LikeYouRepository<Api: NetworkApi & Sendable, Store: LocalApi & Sendable>: Repository where Api.T == LikeItem, Store.T == [LikeItem]? {
    typealias T = [LikeItem]?
    
    private let api: Api
    private let localApi: Store
    
    private var cursor: Int? = nil
    
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
}

// LikeYouRepository is Sendable because its generic members are Sendable.
// Marked as @unchecked because we cannot statically guarantee thread safety.
extension LikeYouRepository: @unchecked Sendable {}

