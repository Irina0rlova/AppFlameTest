import ComposableArchitecture

struct LikeYouRepositoryDependency {
    var load: @Sendable (Int, Int) async throws -> Void
    var getData: @Sendable () -> [LikeItem]?
    var getCursor: @Sendable () -> Int?
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
        }
    )
    
    static let testValue: LikeYouRepositoryDependency = .init(
        load: { _, _ in },
        getData: { [] },
        getCursor:  { nil }
    )
}

extension DependencyValues {
    var likeYouRepository: LikeYouRepositoryDependency {
        get { self[LikeYouRepositoryKey.self] }
        set { self[LikeYouRepositoryKey.self] = newValue }
    }
}

