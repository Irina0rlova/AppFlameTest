import ComposableArchitecture
import Foundation

public struct LikedYouReducer: Reducer, Sendable {
    @Dependency(\.likeYouRepository) var repository
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.realtimeEventsService) var realtimeEventsService

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.unreadItemsCount = 0
            
            let cachedItems = repository.getData()
            let cursor = repository.getCursor()

            return .merge(
                cachedItems == nil
                ? .send(.loadInitial)
                : .send(.initialLoadCompleted(
                    Page(items: cachedItems!, nextCursor: cursor)
                )),
                .run { _ in
                    await realtimeEventsService.startRandomInserts()
                }
                .cancellable(id: CancelID.generator),
                .run { send in
                    for await event in self.realtimeEventsService.events() {
                        switch event {
                        case .likedYouInserted(let item):
                            await send(.newLikeItemReceived(item))
                        case .mutualMatch:
                            break // поки ігноруємо, обробимо окремо
                        }
                    }
                }.cancellable(id: CancelID.realtime)
                )
            
        case .loadInitial:
            state.isLoading = true
            let isBlured = state.isBlured
            
            return .run { send in
                do {
                    try await repository.load(1, 10)
                    repository.updateBluredState(isBlured)
                } catch let error {
                    await send(.initialLoadFailed(message: error.localizedDescription))
                    return
                }
                
                let items = repository.getData() ?? []
                let cursor = repository.getCursor()
                
                await send(.initialLoadCompleted(Page(items: items, nextCursor: cursor)))
            }
            .debounce(id: DebounceId.loadInitial, for: .seconds(0.3), scheduler: mainQueue)
            .cancellable(id: CancelID.loadInitial, cancelInFlight: true)
            
        case .loadNextPage:
            guard !state.isLoading else {
                return .none
            }
            guard let cursor = state.cursor else {
                return .none
            }
            state.isLoading = true

            let isBlured = state.isBlured

            return .run { send in
                do {
                    try await repository.load(cursor, 10)
                    repository.updateBluredState(isBlured)
                } catch {
                    await send(.nextPageFailed)
                    return
                }
                
                let items = repository.getData() ?? []
                let nextCursor = repository.getCursor()
                
                await send(.nextPageCompleted(Page(items: items, nextCursor: nextCursor)))
            }
            .debounce(id: DebounceId.loadNextPage(cursor - 1), for: .seconds(0.3), scheduler: mainQueue)
            .cancellable(id: CancelID.loadNextPage(cursor - 1), cancelInFlight: true)
            
        case .likeTapped(let id):
            guard let item = state.items.first(where: { $0.id == id }) else {
                return .none
            }
            
            return .merge(
                .send(.likeConfirmed(item)),
                .send(.skip(id: id))
            )
            
        case .skip(let id):
            state.items.removeAll(where: { $0.id == id })
            return .run { send in
                await repository.removeItem(id)
            }
            
        case .initialLoadCompleted(let page):
            state.items = page.items
            state.cursor = page.nextCursor
            state.isLoading = false
            return .none
                .debounce(id: CancelID.initialLoadCompleted, for: .seconds(0.3), scheduler: mainQueue)
                // !!!!!.throttle(id: CancelID.initialLoadCompleted, for: .seconds(0.3), scheduler: mainQueue, latest: true)
                .cancellable(id: CancelID.initialLoadCompleted, cancelInFlight: true)
            
        case .nextPageCompleted(let page):
            state.items = page.items
            state.cursor = page.nextCursor
            state.isLoading = false
            return .none
            
        case .initialLoadFailed(_):
            state.isLoading = false
            return .none
            
        case .nextPageFailed:
            state.isLoading = false
            return .none
            
        case .likeConfirmed:
            return .none
            
        case .blur(let isBlured):
            repository.updateBluredState(isBlured)
            state.items = repository.getData() ?? []
            state.isBlured = isBlured
            return .none
            
        case .newLikeItemReceived(let newItem):
            var item = newItem
            item.isBlurred = state.isBlured
            
            if repository.addNewItem(item) {
                state.items.insert(item, at: 0)
                state.unreadItemsCount += 1
            }
            
            return .none
            
        case .onDisappear:
            return .merge(
                .cancel(id: CancelID.generator),
                .cancel(id: CancelID.realtime)
                )
            
        case .resetUnreadItemsCount:
            guard state.unreadItemsCount > 0 else {
                return .none
            }
            
            state.unreadItemsCount = 0
            return .none
        }
    }
    
    public struct State: Equatable, Sendable {
        public var items: [LikeItem] = []
        public var cursor: Int? = nil
        public var isLoading: Bool = false
        public var isBlured: Bool = true
        
        public var unreadItemsCount: Int = 0
    }
    
    public enum Action: Equatable {
        case onAppear
        case onDisappear
        case loadInitial
        case loadNextPage
        
        case initialLoadCompleted(Page<LikeItem>)
        case initialLoadFailed(message: String)
        case nextPageCompleted(Page<LikeItem>)
        case nextPageFailed
        
        case likeTapped(id: UUID)
        case skip(id: UUID)
        case likeConfirmed(LikeItem)
        
        case blur(isBlured: Bool)
        
        case newLikeItemReceived(LikeItem)
        case resetUnreadItemsCount
    }
}

private enum CancelID: Hashable {
    case loadInitial
    case loadNextPage(Int)
    case initialLoadCompleted
    case realtime
    case generator
}

private enum DebounceId: Hashable {
    case loadInitial
    case loadNextPage(Int)
}
