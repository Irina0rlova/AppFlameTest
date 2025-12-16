import XCTest
import Combine
@testable import NotificationCenterFeature

final class LikeYouRepositoryTests: XCTestCase {
    var mockApi: MockApi!
    var mockStore: MockStore!
    var repository: LikeYouRepository<MockApi, MockStore>!
    
    override func setUp() {
        super.setUp()
        
        mockApi = MockApi()
        mockStore = MockStore()
        
        repository = LikeYouRepository(api: mockApi, localApi: mockStore)
    }
    
    override func tearDown() {
        repository = nil
        mockApi = nil
        mockStore = nil
        super.tearDown()
    }
    
    func testLoadSuccessfullyFetchesAndStoresData() async {
        let likeItems: [LikeItem] = [
            LikeItem(id: UUID(), userName: "User 1", avatarURL: URL(string: "https://example.com/avatar1.jpg"), isBlurred: false),
            LikeItem(id: UUID(), userName: "User 2", avatarURL: URL(string: "https://example.com/avatar2.jpg"), isBlurred: false)
        ]
        
        mockApi.mockFetchDataClosure = { _, _ in
            Page(items: likeItems, nextCursor: 3)
        }
        mockStore.storedData = nil
        
        let expectation = self.expectation(description: "Completion called")
        let store = mockStore // avoid capturing self in @Sendable closure
        do {
            _ = try await repository.load(page: 3, batchSize: 10)
            XCTAssertEqual(store?.storedData, likeItems)
            XCTAssertEqual(repository.getCursor(), 3)
            expectation.fulfill()
        } catch {
            XCTFail("Expected to load data successfully but got error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testLoadSuccessfullyFetchesAndUpdateData() async {
        let likeItems: [LikeItem] = [
            LikeItem(id: UUID(), userName: "User 1", avatarURL: URL(string: "https://example.com/avatar1.jpg"), isBlurred: false),
            LikeItem(id: UUID(), userName: "User 2", avatarURL: URL(string: "https://example.com/avatar2.jpg"), isBlurred: false)
        ]
        
        mockApi.mockFetchDataClosure = { _, _ in
            Page(items: likeItems, nextCursor: 3)
        }
        mockStore.storedData = [
            LikeItem(id: UUID(), userName: "User 5", avatarURL: URL(string: "https://example.com/avatar5.jpg"), isBlurred: false)]
        
        let expectation = self.expectation(description: "Completion called")
        let store = mockStore // avoid capturing self in @Sendable closure
        do {
            _ = try await repository.load(page: 1, batchSize: 10)
            XCTAssertEqual(store?.storedData, likeItems)
            XCTAssertEqual(repository.getCursor(), 3)
            expectation.fulfill()
        } catch {
            XCTFail("Expected to load data successfully but got error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testLoadFailsWhenApiFails() async {
        let mockError = NSError(domain: "NetworkError", code: 500, userInfo: nil)
        
        mockApi.mockFetchDataClosure = { _, _ in
            throw mockError
        }
        
        let expectation = self.expectation(description: "Completion called")
        let store = mockStore
        do {
            try await repository.load(page: 1, batchSize: 10)
        } catch let error as NSError {
            XCTAssertEqual(error, mockError)
            XCTAssertNil(store?.storedData) // Data should not be stored
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testGetDataReturnsDataFromLocalApi() {
        // Given
        let likeItems: [LikeItem] = [
            LikeItem(id: UUID(), userName: "User 1", avatarURL: URL(string: "https://example.com/avatar1.jpg"), isBlurred: false)
        ]
        mockStore.storedData = likeItems
        
        // When
        let data = repository.getData()
        
        // Then
        XCTAssertEqual(data, likeItems)
    }
    
    func testGetDataReturnsCursor() async {
        // Given
        let likeItems: [LikeItem] = [
            LikeItem(id: UUID(), userName: "User 1", avatarURL: URL(string: "https://example.com/avatar1.jpg"), isBlurred: false)
        ]
        mockApi.mockFetchDataClosure = { _, _ in
            Page(items: likeItems, nextCursor: 3)
        }
        
        // When
        var cursor = repository.getCursor()
        XCTAssertEqual(cursor, nil)
        
        do {
            try await repository.load(page: 1, batchSize: 10)
            cursor = repository.getCursor()
            // Then
            XCTAssertEqual(cursor, 3)
        } catch let error {
            XCTFail("Expected to load data successfully but got error: \(error)")
        }
    }
    
    func testRemoveItem() async {
        // Given
        let itemToRemove = LikeItem(id: UUID(), userName: "User 1", avatarURL: URL(string: "https://example.com/avatar1.jpg")!, isBlurred: false)
        let otherItem = LikeItem(id: UUID(), userName: "User 2", avatarURL: URL(string: "https://example.com/avatar2.jpg")!, isBlurred: false)
        
        mockStore.storedData = [itemToRemove, otherItem]
        mockApi.mockRemoveItemClosure = { id in
            XCTAssertEqual(id, itemToRemove.id)
        }
        
        // When
        await repository.removeItem(id: itemToRemove.id)
        
        // Then
        XCTAssertEqual(mockStore.storedData?.count, 1)
        XCTAssertEqual(mockStore.storedData?.first, otherItem)
    }
    
    func testRemoveItemIdDoesNotExist() async {
        // Given
        let idToRemove = UUID()
        mockStore.storedData = [
            LikeItem(id: UUID(), userName: "User 1", avatarURL: URL(string: "https://example.com/avatar1.jpg")!, isBlurred: false),
            LikeItem(id: UUID(), userName: "User 2", avatarURL: URL(string: "https://example.com/avatar2.jpg")!, isBlurred: false)
            ]
        mockApi.mockRemoveItemClosure = { id in
            XCTAssertEqual(id, idToRemove)
        }
        
        // When
        await repository.removeItem(id: idToRemove)
        
        // Then
        XCTAssertEqual(mockStore.storedData?.count, 2)
    }
    
    func testRemoveItemNullList() async {
        // Given
        let idToRemove = UUID()
        mockStore.storedData = nil
        mockApi.mockRemoveItemClosure = { id in
            XCTAssertEqual(id, idToRemove)
        }
        
        // When
        await repository.removeItem(id: idToRemove)
        
        // Then
        XCTAssertNil(mockStore.storedData)
    }
}

final class MockApi: NetworkApi, @unchecked Sendable {
    typealias T = LikeItem
    
    var mockFetchDataClosure: ((Int, Int) throws -> Page<LikeItem>)?
    var mockRemoveItemClosure: ((UUID) async -> Void)?
    
    func fetchData(page: Int, batchSize: Int) async throws -> Page<LikeItem> {
        try mockFetchDataClosure!(page, batchSize)
    }
    
    func removeItem(id: UUID) async {
        await mockRemoveItemClosure!(id)
    }
}

final class MockStore: LocalApi, @unchecked Sendable {
    typealias T = [LikeItem]?
    
    var storedData: [LikeItem]?
    
    func createOrUpdate(data: [LikeItem]?) {
        storedData = data
    }
    
    func get() -> [LikeItem]? {
        return storedData
    }
    
    func clear() {
        storedData = nil
    }
}
