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
            let result = try await networkApi.fetchData(page: 1, batchSize: 10)
            XCTAssertNotNil(result.data)
            XCTAssertEqual(result.data?.count, 10)
            XCTAssertEqual(result.nextCursor, 2)
            expectation.fulfill()
        } catch let error {
            XCTFail("Expected success, but got failure with error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 6)
    }
    
    func testFetchData_SuccessNextPage() async throws {
        let expectation = XCTestExpectation(description: "Successfully fetched data")
        
        do {
            let result = try await networkApi.fetchData(page: 3, batchSize: 10)
            XCTAssertNotNil(result.data)
            XCTAssertEqual(result.data?.count, 10)
            XCTAssertEqual(result.nextCursor, 4)
            expectation.fulfill()
        } catch let error {
            XCTFail("Expected success, but got failure with error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 6)
    }
    
    func testFetchData_LastPage() async throws {
        let expectation = XCTestExpectation(description: "Successfully fetched data")
        
        do {
            let result = try await networkApi.fetchData(page: 5, batchSize: 10)
            XCTAssertNotNil(result.data)
            XCTAssertEqual(result.data?.count, 10)
            XCTAssertNil(result.nextCursor)
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
        } catch {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func testGenerateLikeItems_Sleep() async throws {
        let expectation = XCTestExpectation(description: "Completed with delay")
        
        do {
            let result = try await networkApi.fetchData(page: 1, batchSize: 10)
            XCTAssertNotNil(result.data)
            XCTAssertEqual(result.data?.count, 10)
            expectation.fulfill()
        } catch let error {
            XCTFail("Expected success, but got failure with error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: 6)
    }
}

final class MockLikeYouNetworkApi: LikeYouNetworkApi, @unchecked Sendable {
    override func fetchData(page: Int, batchSize: Int) async throws -> (data: [UserModel]?, nextCursor: Int?) {
        throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock failure"])
    }
}
