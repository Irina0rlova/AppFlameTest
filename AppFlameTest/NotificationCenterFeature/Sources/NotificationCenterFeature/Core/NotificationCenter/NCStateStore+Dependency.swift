import ComposableArchitecture
import Foundation

struct NCStateStoreDependency {
    var saveUnblurEndDate: (Date?) -> Void
    var getUnblurEndDate: () -> Date?
}

private enum NCStateStoreKey: DependencyKey {
    static let liveValue = NCStateStore()
    static let testValue = NCStateStore()
}

public extension DependencyValues {
    var ncStateStore: NCStateStore {
        get { self[NCStateStoreKey.self] }
        set { self[NCStateStoreKey.self] = newValue }
    }
}
