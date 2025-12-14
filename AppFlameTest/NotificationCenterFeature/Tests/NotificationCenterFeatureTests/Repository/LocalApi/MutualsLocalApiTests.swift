import Testing
import Foundation
@testable import NotificationCenterFeature

@Suite("MutualsLocalApi Tests")
struct MutualsLocalApiTests {
    @Test
    func testInitialGetReturnsNil() {
        let api = MutualsLocalApi()
        #expect(api.get() == nil)
    }

    @Test
    func testCreateOrUpdateStoresData() {
        let items = [
            LikeItem(id: UUID(), userName: "Item1"),
            LikeItem(id: UUID(), userName: "Item2")
        ]
        let api = MutualsLocalApi()
        api.createOrUpdate(data: items)
        
        let result = api.get()
        #expect(result == items)
        #expect(result?.count == 2)
    }

    @Test
    func testClearData() {
        let items = [LikeItem(id: UUID(), userName: "Item1")]
        let api = MutualsLocalApi()
        api.createOrUpdate(data: items)
        #expect(api.get() != nil)
        
        api.clear()
        #expect(api.get() == nil)
    }

    @Test
    func testOverwriteData() {
        let firstItems = [LikeItem(id: UUID(), userName: "First")]
        let secondItems = [
            LikeItem(id: UUID(), userName: "Second"),
            LikeItem(id: UUID(), userName: "Third")
        ]
        let api = MutualsLocalApi()
        api.createOrUpdate(data: firstItems)
        #expect(api.get() == firstItems)
        
        api.createOrUpdate(data: secondItems)
        #expect(api.get() == secondItems)
    }

    @Test
    func testSetNilData() {
        let firstItems = [LikeItem(id: UUID(), userName: "First")]
        let api = MutualsLocalApi()
        api.createOrUpdate(data: firstItems)
        #expect(api.get() == firstItems)
        
        api.createOrUpdate(data: nil)
        #expect(api.get() == nil)
    }
}
