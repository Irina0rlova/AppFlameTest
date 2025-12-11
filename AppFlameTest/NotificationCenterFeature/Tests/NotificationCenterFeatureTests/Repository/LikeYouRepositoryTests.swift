import XCTest
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
        
        mockApi.mockFetchDataClosure = { _, _, completion in
            completion(.success(likeItems))
        }
        mockStore.storedData = nil
        
        let expectation = self.expectation(description: "Completion called")
        await repository.load(page: 1, batchSize: 10) { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.mockStore.storedData, likeItems)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testLoadFailsWhenApiFails() async {
        let mockError = NSError(domain: "NetworkError", code: 500, userInfo: nil)
        
        mockApi.mockFetchDataClosure = { _, _, completion in
            completion(.failure(mockError))
        }
        
        let expectation = self.expectation(description: "Completion called")
        await repository.load(page: 1, batchSize: 10) { error in
            XCTAssertEqual(error as? NSError, mockError)
            XCTAssertNil(self.mockStore.storedData) // Data should not be stored
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
}



class MockApi: NetworkApi {
    typealias T = [LikeItem]?
    
    var mockFetchDataClosure: ((Int, Int, @escaping (Result<[LikeItem]?, Error>) -> Void) -> Void)?
    
    func fetchData(page: Int, batchSize: Int, completion: @escaping (Result<[LikeItem]?, Error>) -> Void) {
        mockFetchDataClosure?(page, batchSize, completion)
    }
}

class MockStore: LocalApi {
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
