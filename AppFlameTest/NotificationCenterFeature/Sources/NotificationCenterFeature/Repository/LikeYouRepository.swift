protocol Repository {
    associatedtype T
    nonisolated(nonsending)
    func load(page: Int, batchSize: Int, completion: @Sendable @escaping (Error?) -> Void) async
    func getData() -> T
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
    
    nonisolated(nonsending)
    public func load(page: Int, batchSize: Int, completion: @Sendable @escaping (Error?) -> Void) async {
        // Shadow references in a nonisolated(unsafe) manner to avoid capturing self and metatypes.
        let api = self.api
        let localApi = self.localApi

        await api.fetchData(page: page, batchSize: batchSize) { result in
            switch result {
            case .success(let likeItems):
                localApi.createOrUpdate(data: likeItems)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    public func getData() -> [LikeItem]? {
        localApi.get()
    }
}
