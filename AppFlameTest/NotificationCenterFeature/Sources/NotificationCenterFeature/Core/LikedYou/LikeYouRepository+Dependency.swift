import ComposableArchitecture

struct LikeYouRepositoryDependency {
    var load: @Sendable (Int, Int) async throws -> Void
    var getData: @Sendable () -> [LikeItem]?
}

private enum LikeYouRepositoryKey: DependencyKey {
    private static let repository = LikeYouRepository(api: LikeYouNetworkApi(), localApi: LikeLocalApi())

    static let liveValue: LikeYouRepositoryDependency = .init(
        load: { page, batch in
            try await repository.load(page: page, batchSize: batch)
        },
        getData: {
            repository.getData()
        }
    )
    
    static let testValue: LikeYouRepositoryDependency = .init(
        load: { _, _ in },
        getData: { [] }
    )
}

extension DependencyValues {
    var likeYouRepository: LikeYouRepositoryDependency {
        get { self[LikeYouRepositoryKey.self] }
        set { self[LikeYouRepositoryKey.self] = newValue }
    }
}
