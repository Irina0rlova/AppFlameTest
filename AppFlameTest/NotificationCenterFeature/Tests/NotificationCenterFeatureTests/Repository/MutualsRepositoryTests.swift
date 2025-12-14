import Testing
@testable import NotificationCenterFeature

@Suite("MutualsRepository")
struct MutualsRepositoryTests {

    @Test("getData returns empty array when empty")
    func getData_whenEmpty_returnsEmptyArray() async throws {
        let repo = MutualsRepository()
        #expect((await repo.getData()).isEmpty)
    }

    @Test("addMutual stores and returns item")
    func addMutual_thenGetData_returnsItem() async throws {
        let repo = MutualsRepository()
        let item = LikeItem.mock(name: "Alice")
        await repo.addMutual(item)
        let data = await repo.getData()
        #expect(data == [item])
    }

    @Test("getData returns items in reverse order")
    func getData_returnsItemsInReverseOrder() async throws {
        let repo = MutualsRepository()
        let item1 = LikeItem.mock(name: "A")
        let item2 = LikeItem.mock(name: "B")
        await repo.addMutual(item1)
        await repo.addMutual(item2)
        let data = await repo.getData()
        #expect(data == [item2, item1])
    }
}
