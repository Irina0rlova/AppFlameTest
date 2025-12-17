import ComposableArchitecture
import Foundation

struct LikeYouRepositoryDependency {
    var load: @Sendable (Int, Int) async throws -> Void
    var getData: @Sendable () -> [LikeItem]?
    var getCursor: @Sendable () -> Int?
    var removeItem: @Sendable (UUID) async -> Void
    var updateBluredState: @Sendable (Bool) -> Void
}

private enum LikeYouRepositoryKey: DependencyKey {
    private static let repository = LikeYouRepository(api: LikeYouNetworkApi(), localApi: LikeLocalApi())

    static let liveValue: LikeYouRepositoryDependency = .init(
        load: { page, batch in
            try await repository.load(page: page, batchSize: batch)
        },
        getData: {
            repository.getData()
        },
        getCursor: {
            repository.getCursor()
        },
        removeItem: { id in
            await repository.removeItem(id: id)
        },
        updateBluredState: { blur in
            repository.updateBluredState(isBlured: blur)
        }
    )
    
    static let testValue: LikeYouRepositoryDependency = .init(
        load: { _, _ in },
        getData: { [] },
        getCursor:  { nil },
        removeItem: { _ in },
        updateBluredState: { _ in }
    )
}

extension DependencyValues {
    var likeYouRepository: LikeYouRepositoryDependency {
        get { self[LikeYouRepositoryKey.self] }
        set { self[LikeYouRepositoryKey.self] = newValue }
    }
}
