import Foundation

actor MockRealtimeEventsService: RealtimeEventsService {
    private let continuation: AsyncStream<RealtimeEvent>.Continuation
    public let events: AsyncStream<RealtimeEvent>
    
    init() {
        var tempContinuation: AsyncStream<RealtimeEvent>.Continuation! = nil
        self.events = AsyncStream<RealtimeEvent>(bufferingPolicy: .bufferingOldest(1)) { cont in
            tempContinuation = cont
        }
        self.continuation = tempContinuation
    }
    
    func triggerLikedYou(_ item: LikeItem) {
        continuation.yield(.likedYouInserted(item))
    }
    
    func triggerMutualMatch(_ item: LikeItem) {
        continuation.yield(.mutualMatch(item))
    }
    
    func startRandomInserts() async {
        while !Task.isCancelled {
            while true {
                try? await Task.sleep(nanoseconds: UInt64(Int.random(in: 10_000_000_000...15_000_000_000)))
                let newItem = LikeItem(
                    id: UUID(),
                    userName: "User \(Int.random(in: 100...999))",
                    avatarURL: URL(string: "https://randomuser.me/api/portraits/men/\(Int.random(in: 0...99)).jpg"),
                    isBlurred: true
                )
                self.triggerLikedYou(newItem)
            }
        }
    }
    
    func startRandomMutualNotifications() async {
        while true {
            try? await Task.sleep(
                nanoseconds: UInt64(
                    Int.random(in: 8_000_000_000...15_000_000_000)
                )
            )
            
            let item = LikeItem(
                id: UUID(),
                userName: "Mutual \(Int.random(in: 1000...9999))",
                avatarURL: nil,
                isBlurred: false
            )
            
            triggerMutualMatch(item)
        }
    }
}
