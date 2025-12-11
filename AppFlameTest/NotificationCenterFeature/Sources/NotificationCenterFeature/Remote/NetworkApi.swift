public protocol NetworkApi {
    associatedtype T
    func fetchData(page: Int, batchSize: Int, completion: @Sendable @escaping (Result<T, Error>) -> Void) async
}
