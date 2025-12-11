public protocol NetworkApi {
    associatedtype T
    func fetchData(page: Int, batchSize: Int, completion: @escaping (Result<T, Error>) -> Void) async
}
