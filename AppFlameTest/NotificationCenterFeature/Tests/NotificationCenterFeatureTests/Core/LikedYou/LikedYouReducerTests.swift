import XCTest
import ComposableArchitecture
@testable import NotificationCenterFeature

final class LikedYouReducerTests: XCTestCase {
    func testOnAppearTriggersLoadInitial() async {
        //Given
        let expectation = expectation(description: "loadCalled")
        let page = Page(
            items: [
                LikeItem(id: UUID(), userName: "Test", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
            ],
            nextCursor: 2
        )
        let store = await TestStore(
            initialState: LikedYouReducer.State()
        ) {
            LikedYouReducer()
        }
        
        withDependencies: {
            $0.likeYouRepository.load = { _, _ in
                expectation.fulfill()
            }

            $0.likeYouRepository.getData = {
                page.items
            }

            $0.likeYouRepository.getCursor = {
                page.nextCursor
            }
        }

        //When
        await store.send(.onAppear)
        
        //Then
        await store.receive(.loadInitial){
            $0.isLoading = true
        }
        await store.receive(.initialLoadCompleted(page)) {
            $0.items = page.items
            $0.cursor = page.nextCursor
            $0.isLoading = false
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testLoadInitialFetchesPage() async {
        //Given
        let expectation = expectation(description: "loadCalled")
        let page = Page(
            items: [
                LikeItem(id: UUID(), userName: "Test", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
            ],
            nextCursor: 2
        )

        let store = await TestStore(
            initialState: LikedYouReducer.State()
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.likeYouRepository.load = { _, _ in
                expectation.fulfill()
            }

            $0.likeYouRepository.getData = {
                page.items
            }

            $0.likeYouRepository.getCursor = {
                page.nextCursor
            }
        }

        //When
        await store.send(.loadInitial) {
            $0.isLoading = true
        }

        //Then
        await store.receive(.initialLoadCompleted(page)) {
            $0.items = page.items
            $0.cursor = page.nextCursor
            $0.isLoading = false
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testLoadInitialFetchesPageFailed() async {
        //Given
        let expectation = expectation(description: "loadCalled")
        
        UserDefaults.standard.set(["en_US"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        let store = await TestStore(
            initialState: LikedYouReducer.State()
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.likeYouRepository.load = { _, _ in
                expectation.fulfill()
                throw NSError(domain: "TestError", code: 1, userInfo: nil)
            }
        }
        
        //When
        await store.send(.loadInitial) {
            $0.isLoading = true
        }
        
        //Then
        await store.receive(.initialLoadFailed(message: "The operation couldn’t be completed. (TestError error 1.)")) {
            $0.isLoading = false
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testInitialLoadCompleted() async {
        //Given
        let page = Page(
            items: [LikeItem(id: UUID(), userName: "Item 1", avatarURL: URL(string: "https://x.com")!, isBlurred: false)],
            nextCursor: 2
        )
        
        let store = await TestStore(
            initialState: LikedYouReducer.State()
        ) {
            LikedYouReducer()
        }
        
        //When
        await store.send(.initialLoadCompleted(page)) {
            $0.items = page.items
            $0.cursor = page.nextCursor
            $0.isLoading = false
        }
    }

    func testLoadNextPageFetchesNextCursor() async {
        //Given
        let expectation = expectation(description: "loadCalled")
        let initialPage = Page(
            items: [
                LikeItem(id: UUID(), userName: "User1", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
            ],
            nextCursor: 2
        )

        let nextPage = Page(
            items: [
                LikeItem(id: UUID(), userName: "User2", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
            ],
            nextCursor: 3
        )
        
        let expectedPage = Page(
            items: initialPage.items + nextPage.items,
            nextCursor: 3
        )
            
        let store = await TestStore(
            initialState: LikedYouReducer.State()
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.likeYouRepository.load = { _, _ in
                expectation.fulfill()
            }

            $0.likeYouRepository.getData = {
                initialPage.items + nextPage.items
            }

            $0.likeYouRepository.getCursor = {
                nextPage.nextCursor
            }
        }

        //When
        await store.send(.loadNextPage) {
            $0.isLoading = true
        }

        //Then
        await store.receive(.nextPageCompleted(expectedPage)) {
            $0.items = initialPage.items + nextPage.items
            $0.cursor = nextPage.nextCursor
            $0.isLoading = false
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testLoadNextPage_DoesNotDuplicateRequest() async {
        //Given
        let initialPage = Page(
            items: [
                LikeItem(id: UUID(), userName: "User1", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
            ],
            nextCursor: 2
        )

        let loadCallCount = LockIsolated<Int>(0)

        let store = await TestStore(
            initialState: LikedYouReducer.State(
                items: initialPage.items,
                cursor: 2,
                isLoading: true
            )
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.likeYouRepository.load = { _, _ in
                loadCallCount.withValue { $0 += 1 }
            }
        }

        //When
        // has to be ignored
        await store.send(.loadNextPage)

        //Then
        XCTAssertEqual(loadCallCount.value, 0)
    }
}
