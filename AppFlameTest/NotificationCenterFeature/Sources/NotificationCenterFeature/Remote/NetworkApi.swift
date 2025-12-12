public protocol NetworkApi {
    associatedtype T: Equatable
    func fetchData(page: Int, batchSize: Int) async throws -> Page<T>
}
