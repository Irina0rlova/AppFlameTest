protocol Repository {
    associatedtype T
    func load(page: Int, batchSize: Int) async throws
    func getData() async -> T
}

public class LikeYouRepository<Api: NetworkApi & Sendable, Store: LocalApi & Sendable>: Repository where Api.T == [LikeItem]?, Store.T == [LikeItem]? {
    typealias T = [LikeItem]?
    
    private let api: Api
    private let localApi: Store
    
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

        let likeItems = try await api.fetchData(page: page, batchSize: batchSize)
        localApi.createOrUpdate(data: (likeItems!))
    }
    
    public func getData() -> [LikeItem]? {
        localApi.get()
    }
}

// LikeYouRepository is Sendable because its generic members are Sendable.
// Marked as @unchecked because we cannot statically guarantee thread safety.
extension LikeYouRepository: @unchecked Sendable {}

