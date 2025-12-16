import Foundation
import ComposableArchitecture

public struct MutualsReducer: Reducer, Sendable {
    @Dependency(\.mutualsRepository) var repository
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .run { send in
                let items = await repository.getData()
                await send(.mutualsLoaded(items))
            }
            
        case let .mutualsLoaded(items):
            state.items = items
            return .none
            
        case let .addMutual(item):
            let newItem = LikeItem(
                id: item.id,
                userName: item.userName,
                avatarURL: item.avatarURL,
                isBlurred: item.isBlurred,
                isReadOnly: true
            )
            
            state.items.insert(newItem, at: 0)
            return .run { send in
                await repository.addMutual(newItem)
            }
        }
    }
    
    public struct State: Equatable, Sendable {
        public var items: [LikeItem] = []
        
        public init(items: [LikeItem] = []) {
            self.items = items
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case mutualsLoaded([LikeItem])
        
        case addMutual(LikeItem)
    }
    
}
