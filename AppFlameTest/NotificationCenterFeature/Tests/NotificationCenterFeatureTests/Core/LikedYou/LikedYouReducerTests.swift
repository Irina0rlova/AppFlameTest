import XCTest
import ComposableArchitecture
@testable import NotificationCenterFeature

final class LikedYouReducerTests: XCTestCase {

    func testOnAppearTriggersLoadInitial() async {
        let store = await TestStore(
            initialState: LikedYouReducer.State()
        ) {
            LikedYouReducer()
        }

        await store.send(.onAppear)
        await store.receive(.loadInitial)
    }

    func testLoadInitialFetchesData() async {
        let expectation = expectation(description: "loadCalled")
        let returnedItems: [LikeItem] = [
            LikeItem.mock()
        ]
        
        let store = await TestStore(initialState: LikedYouReducer.State()) {
            LikedYouReducer()
        } withDependencies: {
            $0.likeYouRepository.load = { _, _ in
                expectation.fulfill()
            }
            $0.likeYouRepository.getData = {
                returnedItems
            }
        }
        
        await store.send(.loadInitial) {
            $0.isLoading = true
        }
        
//        await store.receive(.pageResponse(.success(returnedItems))) {
//            $0.items = returnedItems
//            $0.isLoading = false
//        }
        
        //XCTAssertTrue(loadCalled)
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }

}
