public protocol NetworkApi {
    associatedtype T
    func fetchData(page: Int, batchSize: Int) async throws -> T
}
