import ComposableArchitecture
import Foundation

public struct LikedYouReducer: Reducer, Sendable {
    @Dependency(\.likeYouRepository) var repository
    @Dependency(\.mainQueue) var mainQueue

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            guard let items = repository.getData() else {
                return .send(.loadInitial)
            }
            
            let cursor = repository.getCursor()
            return .send(.initialLoadCompleted(Page(items: items, nextCursor: cursor)))
            
        case .loadInitial:
            state.isLoading = true
            
            return .run { send in
                do {
                    try await repository.load(1, 10)
                } catch let error {
                    await send(.initialLoadFailed(message: error.localizedDescription))
                    return
                }
                
                let items = repository.getData() ?? []
                let cursor = repository.getCursor()
                
                await send(.initialLoadCompleted(Page(items: items, nextCursor: cursor)))
            }
            .debounce(id: CancelID.loadInitial, for: .seconds(0.3), scheduler: mainQueue)
            .cancellable(id: CancelID.loadInitial, cancelInFlight: true)
            
        case .loadNextPage:
            guard !state.isLoading
            else {
                return .none
            }
            
            guard let cursor = state.cursor else {
                return .none
            }
            state.isLoading = true
            
            return .run { send in
                do {
                    try await repository.load(cursor, 10)
                } catch {
                    await send(.nextPageFailed)
                    return
                }
                
                let items = repository.getData() ?? []
                let nextCursor = repository.getCursor()
                
                await send(.nextPageCompleted(Page(items: items, nextCursor: nextCursor)))
            }
            .debounce(id: CancelID.loadNextPage(state.cursor! - 1), for: .seconds(0.3), scheduler: mainQueue)
            .cancellable(id: CancelID.loadNextPage(state.cursor! - 1))
            
        case .likeTapped(let id):
            guard let item = state.items.first(where: { $0.id == id }) else {
                return .none
            }
            
            return .merge(
                .send(.likeConfirmed(item)),
                .send(.skip(id: id))
            )
            
        case .skip(let id):
            return .run { send in
                await repository.removeItem(id)
                let items = repository.getData() ?? []
                let nextCursor = repository.getCursor()
                
                await send(.initialLoadCompleted(Page(items: items, nextCursor: nextCursor)))
            } //можна просто оновити state.items !!!!!!!!!!!
            
        case .initialLoadCompleted(let page):
            state.items = page.items
            state.cursor = page.nextCursor
            state.isLoading = false
            return .none
            
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
        }
    }
    
    public struct State: Equatable {
        public var items: [LikeItem] = []
        public var cursor: Int? = nil
        public var isLoading: Bool = false
//        public var hasMore: Bool {
//            cursor != nil
//        }
        
        //public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadInitial
        case loadNextPage
        
        case initialLoadCompleted(Page<LikeItem>)
        case initialLoadFailed(message: String)
        case nextPageCompleted(Page<LikeItem>)
        case nextPageFailed
        
        case likeTapped(id: UUID)
        case skip(id: UUID)
        
        case likeConfirmed(LikeItem)
    }
}

private enum CancelID: Hashable {
    case loadInitial
    case loadNextPage(Int)
}

