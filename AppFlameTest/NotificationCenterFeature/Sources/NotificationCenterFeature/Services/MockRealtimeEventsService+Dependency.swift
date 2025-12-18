import ComposableArchitecture
import Foundation

struct RealtimeEventsServiceDependency {
    var startRandomInserts: @Sendable () async -> Void
    var events: @Sendable () -> AsyncStream<RealtimeEvent>
}

extension DependencyValues {
    var realtimeEventsService: RealtimeEventsServiceDependency {
        get { self[RealtimeEventsServiceKey.self] }
        set { self[RealtimeEventsServiceKey.self] = newValue }
    }
}

private enum RealtimeEventsServiceKey: DependencyKey {
    static let service = MockRealtimeEventsService()
    
    static let liveValue: RealtimeEventsServiceDependency = .init(
        startRandomInserts: {
            await service.startRandomInserts()
        },
        events: {
            service.events
        }
    )
    
    static let testValue: RealtimeEventsServiceDependency = .init(
        startRandomInserts: {},
        events: { AsyncStream { $0.finish() }}
    )
}
