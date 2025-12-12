import ComposableArchitecture
import Foundation

public struct LikedYouReducer: Reducer {
    @Dependency(\.likeYouRepository) var repository
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .onAppear:
            return .send(.loadInitial)
            
        case .loadInitial:
            return .none
            
        case .loadNextPage:
            return .none
            
        case .likeTapped:
            return .none
            
        case .discardTapped:
            return .none
        }
    }
    
    public struct State: Equatable {
        public var items: [LikeItem] = []
        //public var cursor: String? = nil
        public var isLoading: Bool = false
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadInitial
        case loadNextPage
        
        case likeTapped(id: UUID)
        case discardTapped(id: UUID)
    }
}

