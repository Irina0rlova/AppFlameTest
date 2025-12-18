import Foundation

public protocol NetworkApi {
    func fetchData(page: Int, batchSize: Int) async throws -> (data: [UserModel]?, nextCursor: Int?)
    func removeItem(id: UUID) async
}
