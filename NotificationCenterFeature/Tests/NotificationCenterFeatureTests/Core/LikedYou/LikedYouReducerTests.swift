import XCTest
import ComposableArchitecture
@testable import NotificationCenterFeature

final class LikedYouReducerTests: XCTestCase {
    func testOnAppearTriggersLoadInitial() async {
        //Given
        let expectation = expectation(description: "loadCalled")
        let scheduler = DispatchQueue.test
        let itemsBox = LockIsolated<[LikeItem]?>(nil)
        let page = Page(
            items: [
                LikeItem(id: UUID(), userName: "Test", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
            ],
            nextCursor: 2
        )
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                isBlured: false
            )
        ) {
            LikedYouReducer()
        }
        
        withDependencies: {
            $0.mainQueue = scheduler.eraseToAnyScheduler()
            $0.likeYouRepository.load = { _, _ in
                expectation.fulfill()
            }
            
            $0.likeYouRepository.getData = {
                itemsBox.value
            }
            
            $0.likeYouRepository.getCursor = {
                page.nextCursor
            }
        }
        
        //When
        await store.send(.onAppear)
        
        //Then
        itemsBox.setValue(page.items)
        await store.receive(.loadInitial){
            $0.isLoading = true
        }
        await scheduler.advance(by: .seconds(0.3))
        await store.receive(.initialLoadCompleted(page)) {
            $0.items = page.items
            $0.cursor = page.nextCursor
            $0.isLoading = false
        }
        await scheduler.advance(by: .seconds(0.3))
        await store.receive(.blur(isBlured: false))
        await store.send(.onDisappear)
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testOnAppearTriggers_DataExist() async {
        //Given
        let scheduler = DispatchQueue.test
        let page = Page(
            items: [
                LikeItem(id: UUID(), userName: "Test", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
            ],
            nextCursor: 2
        )
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                isBlured: true
            )
        ) {
            LikedYouReducer()
        }
        
        withDependencies: {
            $0.mainQueue = scheduler.eraseToAnyScheduler()
            
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
        await scheduler.advance(by: .seconds(0.3))
        await store.receive(.initialLoadCompleted(page)) {
            $0.items = page.items
            $0.cursor = page.nextCursor
            $0.isLoading = false
        }
        await store.receive(.blur(isBlured: true))
        await store.send(.onDisappear)
    }
    
    func testOnAppearTriggers_UnreadCounter() async {
        //Given
        let scheduler = DispatchQueue.test
        let page = Page(
            items: [
                LikeItem(id: UUID(), userName: "Test", avatarURL: URL(string: "https://x.com")!, isBlurred: false)
            ],
            nextCursor: 2
        )
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                isBlured: true,
                unreadItemsCount: 4
            )
        ) {
            LikedYouReducer()
        }
        
        withDependencies: {
            $0.mainQueue = scheduler.eraseToAnyScheduler()
            
            $0.likeYouRepository.getData = {
                page.items
            }
            
            $0.likeYouRepository.getCursor = {
                page.nextCursor
            }
        }
        
        //When
        await store.send(.onAppear) {
            $0.unreadItemsCount = 0
        }
        
        //Then
        await scheduler.advance(by: .seconds(0.3))
        await store.receive(.initialLoadCompleted(page)) {
            $0.items = page.items
            $0.cursor = page.nextCursor
            $0.isLoading = false
        }
        await store.receive(.blur(isBlured: true))
        
        await store.send(.onDisappear)
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
            initialState: LikedYouReducer.State(
                isBlured: true
            )
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
        await scheduler.advance(by: .seconds(0.3))
        await store.receive(.blur(isBlured: true))
        await store.send(.onDisappear)
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
        
        await store.send(.onDisappear)
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testInitialLoadCompleted() async {
        //Given
        let scheduler = DispatchQueue.test
        let page = Page(
            items: [LikeItem(id: UUID(), userName: "Item 1", avatarURL: URL(string: "https://x.com")!, isBlurred: false)],
            nextCursor: 2
        )
        
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                isBlured: true
            )
        ) {
            LikedYouReducer()
        } withDependencies: {
            $0.mainQueue = scheduler.eraseToAnyScheduler()
            
            $0.likeYouRepository.getData = {
                page.items
            }
            
            $0.likeYouRepository.getCursor = {
                page.nextCursor
            }
        }
        
        //When
        await store.send(.initialLoadCompleted(page)) {
            $0.items = page.items
            $0.cursor = page.nextCursor
            $0.isLoading = false
        }
        
        //Then
        await scheduler.advance(by: .seconds(0.3))
        await store.receive(.blur(isBlured: true))
        await store.send(.onDisappear)
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
        
        await store.send(.onDisappear)
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
        let expectation = expectation(description: "removeItemCalled")
        let idForRemove = UUID()
        let item = LikeItem.mock()
        let initialPage = Page(
            items: [
                LikeItem(id: idForRemove, userName: "User1", avatarURL: URL(string: "https://x.com")!, isBlurred: false),
                item
            ],
            nextCursor: 2
        )
        let expectedPage = Page(
            items: [item],
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
        }
        
        // When
        await store.send(.skip(id: idForRemove)) {
            $0.items = expectedPage.items
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testSkipTappedRemovesItemEmptyList() async {
        // Given
        let expectation = expectation(description: "removeItemCalled")
        let idForRemove = UUID()
        let initialPage = Page(
            items: [
                LikeItem(id: idForRemove, userName: "User1", avatarURL: URL(string: "https://x.com")!, isBlurred: false),
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
        await store.send(.skip(id: idForRemove)) {
            $0.items = expectedPage.items
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testNewLikeItemReceived_insertsItemAndIncrementsUnreadCount() async {
        let initialItem = LikeItem(
            id: UUID(),
            userName: "Existing User",
            avatarURL: nil,
            isBlurred: true
        )
        
        let newItem = LikeItem(
            id: UUID(),
            userName: "New User",
            avatarURL: nil,
            isBlurred: true
        )
        
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                items: [initialItem],
                cursor: nil,
                isLoading: false,
                isBlured: true,
                unreadItemsCount: 0
            )) {
                LikedYouReducer()
            } withDependencies: {
                _ = $0.likeYouRepository.addNewItem(newItem)
            }
        
        await store.send(.newLikeItemReceived(newItem)) {
            $0.items = [newItem, initialItem]
            $0.unreadItemsCount = 1
        }
    }
    
    func testNewLikeItemReceived_insertsItemFailed() async {
        let initialItem = LikeItem(
            id: UUID(),
            userName: "Existing User",
            avatarURL: nil,
            isBlurred: true
        )
        
        let newItem = LikeItem(
            id: UUID(),
            userName: "New User",
            avatarURL: nil,
            isBlurred: true
        )
        
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                items: [initialItem],
                cursor: nil,
                isLoading: false,
                isBlured: true,
                unreadItemsCount: 0
            )) {
                LikedYouReducer()
            } withDependencies: {
                $0.likeYouRepository.addNewItem = { _ in false }
            }
        
        await store.send(.newLikeItemReceived(newItem))
    }
    
    func testDidScrollToTopResetsUnreadCount() async {
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                unreadItemsCount: 3
            )
        ) {
            LikedYouReducer()
        }
        
        await store.send(.resetUnreadItemsCount) {
            $0.unreadItemsCount = 0
        }
    }
    
    func testDidScrollToTopUnreadIsZero() async {
        let store = await TestStore(
            initialState: LikedYouReducer.State(
                unreadItemsCount: 0
            )
        ) {
            LikedYouReducer()
        }
        
        await store.send(.resetUnreadItemsCount)
    }
}
