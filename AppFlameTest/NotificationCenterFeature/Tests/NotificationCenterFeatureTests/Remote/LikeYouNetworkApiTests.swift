import XCTest
@testable import NotificationCenterFeature

final class LikeYouNetworkApiTests: XCTestCase {
    var networkApi: LikeYouNetworkApi!
    
    override func setUpWithError() throws {
        super.setUp()
        networkApi = LikeYouNetworkApi()
    }
    
    override func tearDownWithError() throws {
        networkApi = nil
        super.tearDown()
    }
    
    func testFetchData_Success() async throws {
        let expectation = XCTestExpectation(description: "Successfully fetched data")
        
        do {
            let likeItems = try await networkApi.fetchData(page: 1, batchSize: 10)
            XCTAssertNotNil(likeItems)
            XCTAssertEqual(likeItems.items.count, 10)
            expectation.fulfill()
        } catch let error {
            XCTFail("Expected success, but got failure with error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 6)
    }
    
    func testFetchData_SuccessNextPage() async throws {
        let expectation = XCTestExpectation(description: "Successfully fetched data")
        
        do {
            let likeItems = try await networkApi.fetchData(page: 3, batchSize: 10)
            XCTAssertNotNil(likeItems)
            XCTAssertEqual(likeItems.items.count, 10)
            expectation.fulfill()
        } catch let error {
            XCTFail("Expected success, but got failure with error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 6)
    }
    
    func testFetchData_Failure() async throws {
        let expectation = XCTestExpectation(description: "Failed to fetch data due to error")
        
        let mockApi = MockLikeYouNetworkApi()
        do {
            _ = try await mockApi.fetchData(page: 1, batchSize: 10)
            XCTFail("Expected failure, but got success")
        } catch let error {
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func testGenerateLikeItems_Sleep() async throws {
        let expectation = XCTestExpectation(description: "Completed with delay")
        
        do {
            let likeItems = try await networkApi.fetchData(page: 1, batchSize: 10)
            XCTAssertNotNil(likeItems)
            XCTAssertEqual(likeItems.items.count, 10)
            expectation.fulfill()
        } catch let error {
            XCTFail("Expected success, but got failure with error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 6)
    }
}

class MockLikeYouNetworkApi: LikeYouNetworkApi, @unchecked Sendable {
    override func fetchData(page: Int, batchSize: Int) async throws -> Page<LikeItem> {
        throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock failure"])
    }
}
