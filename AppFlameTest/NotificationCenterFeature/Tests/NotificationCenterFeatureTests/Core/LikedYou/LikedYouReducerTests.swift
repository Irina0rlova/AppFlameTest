import XCTest
import ComposableArchitecture
@testable import NotificationCenterFeature

final class LikedYouReducerTests: XCTestCase {
    func testOnAppearTriggersLoadInitial() async {
        //Given
        let expectation = expectation(description: "loadCalled")
        let scheduler = DispatchQueue.test
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
            $0.mainQueue = scheduler.eraseToAnyScheduler()
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
        await scheduler.advance(by: .seconds(0.3))
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
        let scheduler = DispatchQueue.test
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
            $0.mainQueue = scheduler.eraseToAnyScheduler()
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
        await scheduler.advance(by: .seconds(0.3))
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
        let scheduler = DispatchQueue.test
        
        UserDefaults.standard.set(["en_US"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        let store = await TestStore(
            initialState: LikedYouReducer.State()
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.mainQueue = scheduler.eraseToAnyScheduler()
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
        await scheduler.advance(by: .seconds(0.3))
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
        let scheduler = DispatchQueue.test
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
            initialState: LikedYouReducer.State(
                items: initialPage.items,
                cursor: 1,
                isLoading: false
            )
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.mainQueue = scheduler.eraseToAnyScheduler()
            
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
        await scheduler.advance(by: .seconds(0.3))
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
    
    func testLoadNextPageLastPage() async {
        //Given
        let scheduler = DispatchQueue.test
            
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                    items: [],
                    cursor: nil,
                    isLoading: false
            )
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.mainQueue = scheduler.eraseToAnyScheduler()
        }

        //When
        await store.send(.loadNextPage)

        //Then
        await scheduler.advance(by: .seconds(0.3))
    }
    
    func testSkipTappedRemovesItemAndUpdatesState() async {
        // Given
        let expectation = expectation(description: "loadCalled")
        let idForRemove = UUID()
        let initialPage = Page(
            items: [
                LikeItem(id: idForRemove, userName: "User1", avatarURL: URL(string: "https://x.com")!, isBlurred: false),
                LikeItem.mock()
            ],
            nextCursor: 2
        )
        let expectedPage = Page(
            items: [LikeItem.mock()],
            nextCursor: 2
        )
        
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                items: initialPage.items,
                cursor: 2,
                isLoading: false
            )
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.likeYouRepository.removeItem = { _ in
                expectation.fulfill()
            }
            
            $0.likeYouRepository.getData = {
                expectedPage.items
            }

            $0.likeYouRepository.getCursor = {
                expectedPage.nextCursor
            }
        }
        
        // When
        await store.send(.skip(id: idForRemove))
        
        // Then
        await store.receive(.initialLoadCompleted(expectedPage)) {
            $0.items = expectedPage.items
            $0.cursor = expectedPage.nextCursor
            $0.isLoading = false
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testSkipTappedRemovesItemEmptyList() async {
        // Given
        let expectation = expectation(description: "loadCalled")
        let idForRemove = UUID()
        let initialPage = Page(
            items: [
                LikeItem(id: idForRemove, userName: "User1", avatarURL: URL(string: "https://x.com")!, isBlurred: false),
                LikeItem.mock()
            ],
            nextCursor: 2
        )
        let emptyItems: [LikeItem] = []
        let expectedPage = Page(
            items: emptyItems,
            nextCursor: 2
        )
        
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                items: initialPage.items,
                cursor: 2,
                isLoading: false
            )
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.likeYouRepository.removeItem = { _ in
                expectation.fulfill()
            }
            
            $0.likeYouRepository.getData = {
                nil
            }

            $0.likeYouRepository.getCursor = {
                expectedPage.nextCursor
            }
        }
        
        // When
        await store.send(.skip(id: idForRemove))
        
        // Then
        await store.receive(.initialLoadCompleted(expectedPage)) {
            $0.items = expectedPage.items
            $0.cursor = expectedPage.nextCursor
            $0.isLoading = false
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    
//    func testLoadNextPage_Debounced() async {
//        let clock = TestClock()
//
//        let initialPage = Page(
//            items: [
//                LikeItem(id: UUID(), userName: "User1", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
//            ],
//            nextCursor: 2
//        )
//
//        let nextPage = Page(
//            items: [
//                LikeItem(id: UUID(), userName: "User2", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
//            ],
//            nextCursor: 3
//        )
//        
//        let expectedPage = Page(
//            items: initialPage.items + nextPage.items,
//            nextCursor: 3
//        )
//
//        let loadCallCount = LockIsolated(0)
//
//        let store = TestStore(
//            initialState: LikedYouReducer.State(
//                items: initialPage.items,
//                cursor: 2,
//                isLoading: false
//            )
//        ) {
//            LikedYouReducer()
//        } withDependencies: {
//            $0.mainQueue = DispatchQueue.s
//            $0.likeYouRepository.load = { _, _ in
//                loadCallCount.withValue { $0 += 1 }
//            }
//            $0.likeYouRepository.getData = {
//                expectedPage.items
//            }
//            $0.likeYouRepository.getCursor = {
//                expectedPage.nextCursor
//            }
//        }
//
//        await store.send(.loadNextPage)
//        await store.send(.loadNextPage)
//        await store.send(.loadNextPage)
//
//        XCTAssertEqual(loadCallCount.value, 0)
//
//        await clock.advance(by: .milliseconds(299))
//        XCTAssertEqual(loadCallCount.value, 0)
//
//        await clock.advance(by: .milliseconds(1))
//
//        XCTAssertEqual(loadCallCount.value, 1)
//
//        await store.receive(.nextPageCompleted(expectedPage)) {
//            $0.items = initialPage.items + nextPage.items
//            $0.cursor = expectedPage.nextCursor
//            $0.isLoading = false
//        }
//    }
    
    /*func testDebounceOnLoadInitial() async {
        let expectation = expectation(description: "debounce triggered")
        
        let initialPage = Page(
            items: [
                LikeItem(id: UUID(), userName: "User1", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
            ],
            nextCursor: 2
        )

//        let nextPage = Page(
//            items: [
//                LikeItem(id: UUID(), userName: "User2", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
//            ],
//            nextCursor: 3
//        )
//        
//        let expectedPage = Page(
//            items: initialPage.items + nextPage.items,
//            nextCursor: 3
//        )
        
        let loadCallCount = LockIsolated(0)
            
        let store = await TestStore(
            initialState: LikedYouReducer.State()
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.likeYouRepository.load = { _, _ in
                loadCallCount.withValue { $0 += 1 }
                expectation.fulfill()
            }

            $0.likeYouRepository.getData = {
                initialPage.items
            }

            $0.likeYouRepository.getCursor = {
                initialPage.nextCursor
            }
        }
        
        await store.send(.loadInitial) {
            $0.isLoading = true
        }
        await store.send(.loadInitial)
        await store.send(.loadInitial)
        
        XCTAssertEqual(loadCallCount.value, 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            //expectation.fulfill()
            XCTAssertEqual(loadCallCount.value, 1)
        }
        
        await store.receive(.nextPageCompleted(initialPage)) {
            $0.items = initialPage.items
            $0.cursor = initialPage.nextCursor
            $0.isLoading = false
        }
        
        await fulfillment(of: [expectation], timeout: 1)
    }
*/
}
