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
            return .run { send in
                await repository.addMutual(item)
                await send(.mutualsLoaded(await repository.getData()))
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
