import Testing
import Foundation
@testable import NotificationCenterFeature

@Suite("LikeLocalApi Tests")
struct LikeLocalApiTests {
    @Test
    func testInitialGetReturnsNil() {
        let api = LikeLocalApi()
        #expect(api.get() == nil)
    }

    @Test
    func testCreateOrUpdateStoresData() {
        let items = [
            LikeItem(id: UUID(), userName: "Item1"),
            LikeItem(id: UUID(), userName: "Item2")
        ]
        let api = LikeLocalApi()
        api.createOrUpdate(data: items)
        
        let result = api.get()
        #expect(result == items)
        #expect(result?.count == 2)
    }

    @Test
    func testClearData() {
        let items = [LikeItem(id: UUID(), userName: "Item1")]
        let api = LikeLocalApi()
        api.createOrUpdate(data: items)
        #expect(api.get() != nil)
        
        api.clear()
        #expect(api.get() == nil)
    }

    @Test
    func testUpdateOverwritesPreviousData() {
        let ids = [UUID(), UUID(), UUID()]
        let firstItems = [LikeItem(id: ids[0], userName: "First")]
        let secondItems = [
            LikeItem(id: ids[1], userName: "Second"),
            LikeItem(id: ids[2], userName: "Third")
        ]
        let expectedItems = [
            LikeItem(id: ids[0], userName: "First"),
            LikeItem(id: ids[1], userName: "Second"),
            LikeItem(id: ids[2], userName: "Third")
        ]
        let api = LikeLocalApi()
        api.createOrUpdate(data: firstItems)
        #expect(api.get()?.count == 1)
        #expect(api.get() == firstItems)
        
        api.createOrUpdate(data: secondItems)
        #expect(api.get()?.count == 3)
        #expect(api.get() == expectedItems)
    }
}
