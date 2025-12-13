import ComposableArchitecture
import Foundation

public struct LikedYouReducer: Reducer, Sendable {
    @Dependency(\.likeYouRepository) var repository
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .onAppear:
            return .send(.loadInitial)
            
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
            
        case .loadNextPage:
            guard !state.isLoading
            else {
                return .none
            }
            
            state.isLoading = true
            let cursor = state.cursor ?? 1
            
            return .run { send in
                do {
                    try await repository.load(cursor, 10)
                } catch _ {
                    await send(.nextPageFailed)
                    return
                }
                
                let items = repository.getData() ?? []
                let nextCursor = repository.getCursor()
                
                await send(.nextPageCompleted(Page(items: items, nextCursor: nextCursor)))
            }
            
        case .likeTapped:
            return .none
            
        case .discardTapped:
            return .none
            
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
        case discardTapped(id: UUID)
    }
}

