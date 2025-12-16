import XCTest
import ComposableArchitecture
@testable import NotificationCenterFeature

final class MutualsReducerTests: XCTestCase {
    func testOnAppearLoadsMutuals() async {
        //Given
        let expectation = expectation(description: "getDataCalled")
        let item = LikeItem.mock()
        let repository = MutualsRepository()
        await repository.addMutual(item)
        
        let store = await TestStore(
            initialState: MutualsReducer.State()
        ) {
            MutualsReducer()
        } withDependencies: {
            $0.mutualsRepository = repository
            expectation.fulfill()
        }
        
        //When
        await store.send(.onAppear)
        
        //Then
        await store.receive(.mutualsLoaded([item])) {
            $0.items = [item]
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testMutualsLoadedUpdatesState() async {
        //Given
        let items = [LikeItem.mock()]

        let store = await TestStore(
            initialState: MutualsReducer.State()
        ) {
            MutualsReducer()
        }

        //When
        await store.send(.mutualsLoaded(items)) {
            $0.items = items
        }
    }
    
    func testAddMutual_AddsItemAndReloads() async {
        //Given
        let expectation = expectation(description: "addMutualCalled")
        let item = LikeItem.mock()

        let repository = MutualsRepository()
        let store = await TestStore(
            initialState: MutualsReducer.State()
        ) {
            MutualsReducer()
        } withDependencies: {
            $0.mutualsRepository = repository
            expectation.fulfill()
        }

        //When
        await store.send(.addMutual(item)) {
            $0.items = [item]
        }

        //Then
        await fulfillment(of: [expectation], timeout: 5)
    }
}
