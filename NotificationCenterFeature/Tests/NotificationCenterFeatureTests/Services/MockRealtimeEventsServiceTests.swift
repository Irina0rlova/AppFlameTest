@testable import NotificationCenterFeature
import XCTest

final class MockRealtimeEventsServiceTests: XCTestCase {
    func testRealtimeMock() async {
        let service = MockRealtimeEventsService()
        
        Task {
            for await event in await service.events {
                switch event {
                case .likedYouInserted(let item):
                    print("New liked you: \(item.id)")
                case .mutualMatch(let item):
                    print("Mutual match! \(item.id)")
                }
            }
        }
        
        await service.triggerLikedYou(LikeItem.mock())
        await service.triggerMutualMatch(LikeItem.mock())
    }
}
