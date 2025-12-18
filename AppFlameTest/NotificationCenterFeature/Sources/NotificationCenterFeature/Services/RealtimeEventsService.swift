public enum RealtimeEvent: Sendable, Equatable {
    case likedYouInserted(LikeItem)
    case mutualMatch(LikeItem)
}

public protocol RealtimeEventsService: Sendable {
    var events: AsyncStream<RealtimeEvent> { get }
}
