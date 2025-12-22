import ComposableArchitecture

struct MutualsRepositoryDependency {
    var getData: () -> [LikeItem]
    var addMutual: (_ likeItem: LikeItem) -> Void
}

private enum MutualsRepositoryKey: DependencyKey {
    static let liveValue = MutualsRepository()
    static let testValue = MutualsRepository()
}

public extension DependencyValues {
    var mutualsRepository: MutualsRepository {
        get { self[MutualsRepositoryKey.self] }
        set { self[MutualsRepositoryKey.self] = newValue }
    }
}
