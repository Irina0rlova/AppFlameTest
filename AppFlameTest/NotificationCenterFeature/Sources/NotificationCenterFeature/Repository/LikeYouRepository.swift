protocol Repository {
    associatedtype T
    func load(page: Int, batchSize: Int, completion: @escaping (Error?) -> Void) async
    func getData() -> T
}

public class LikeYouRepository<Api: NetworkApi, Store: LocalApi>: Repository where Api.T == [LikeItem]?, Store.T == [LikeItem]? {
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
    
    public func load(page: Int, batchSize: Int, completion: @escaping (Error?) -> Void) async {
        await api.fetchData(page: page, batchSize: batchSize) { result in
            switch result {
            case .success(let likeItems):
                self.localApi.createOrUpdate(data: likeItems)
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
