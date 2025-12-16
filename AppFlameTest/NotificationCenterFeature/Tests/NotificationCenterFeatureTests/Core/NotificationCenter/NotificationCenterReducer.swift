import XCTest
import Combine
import ComposableArchitecture
@testable import NotificationCenterFeature

let mockLikedItems = Page(
    items: [
    LikeItem(id: UUID(), userName: "Test User 1", avatarURL: URL(string: "https://example.com/avatar1.jpg")!, isBlurred: false)
    ],
    nextCursor: 2)

let mockMutualsItems: [LikeItem] = [
    LikeItem(id: UUID(), userName: "Test User 2", avatarURL: URL(string: "https://example.com/avatar2.jpg")!, isBlurred: false)
]

final class NCReducerTests: XCTestCase {
    func testLikedYouAction() async {
        //Given
        let expectation = expectation(description: "loadCalled")
        let scheduler = DispatchQueue.test
        let initialState = NCReducer.State(
            likedYou: LikedYouReducer.State(items: []),
            mutuals: MutualsReducer.State(items: [])
        )

        let store = await TestStore(
            initialState: initialState
        ) {
            NCReducer()
        } withDependencies: {
            $0.mainQueue = scheduler.eraseToAnyScheduler()
            $0.likeYouRepository.load = { _, _ in
                expectation.fulfill()
            }

            $0.likeYouRepository.getData = {
                mockLikedItems.items
            }

            $0.likeYouRepository.getCursor = {
                mockLikedItems.nextCursor
            }        }

        //When
        await store.send(.likedYou(.onAppear))

        //Then
        await store.receive(.likedYou(.loadInitial)){
            $0.likedYou.isLoading = true
        }
        await scheduler.advance(by: .seconds(0.3))
        await store.receive(.likedYou(.initialLoadCompleted(mockLikedItems))) {
            $0.likedYou.items = mockLikedItems.items
            $0.likedYou.cursor = mockLikedItems.nextCursor
            $0.likedYou.isLoading = false
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testMutualsAction() async {
        //Given
        let initialState = NCReducer.State(
            likedYou: LikedYouReducer.State(items: []),
            mutuals: MutualsReducer.State(items: [])
        )
        let repository = MutualsRepository()
        await repository.addMutual(mockMutualsItems.first!)

        let store = await TestStore(
            initialState: initialState
        ) {
            NCReducer()
        } withDependencies: {
            $0.mutualsRepository = repository
        }

        //When
        await store.send(.mutuals(.onAppear)) 

        //Then
        await store.receive(.mutuals(.mutualsLoaded(mockMutualsItems))) {
            $0.mutuals.items = mockMutualsItems
        }
    }
    
    func testLikeMovesProfileToMutuals() async {
        //Given
        let item = LikeItem.mock()
        let expectedPage = Page(items: [LikeItem](), nextCursor: nil)
        let mutualsRepository = MutualsRepository()

        let store = await TestStore(
            initialState: NCReducer.State(
                likedYou: LikedYouReducer.State(
                    items: [item],
                    cursor: nil,
                    isLoading: false
                ),
                mutuals: MutualsReducer.State()
            )
        ) {
            NCReducer()
        } withDependencies: {
            $0.mutualsRepository = mutualsRepository
        }

        //When
        await store.send(.likedYou(.likeTapped(id: item.id)))

        //Then
        await store.receive(.likedYou(.likeConfirmed(item)))
        await store.receive(.likedYou(.skip(id: item.id)))
        await store.receive(.mutuals(.addMutual(item))){
            $0.mutuals.items = [item]
        }
        await store.receive(.likedYou(.initialLoadCompleted(expectedPage))) {
            $0.likedYou.items = expectedPage.items
            $0.likedYou.cursor = expectedPage.nextCursor
            $0.likedYou.isLoading = false
        }
    }

}

// Here should be tested the whole LikedYouReducer and MutualsReducer
