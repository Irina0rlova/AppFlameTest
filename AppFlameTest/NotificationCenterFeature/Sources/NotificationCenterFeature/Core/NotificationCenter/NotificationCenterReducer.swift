import ComposableArchitecture

public struct NCReducer: Reducer {
    private let likedYouReducer = LikedYouReducer()
    private let mutualsReducer = MutualsReducer()
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .likedYou(.likeConfirmed(let item)):
            return .send(.mutuals(.addMutual(item)))
            
        case .likedYou(let likedYouAction):
            return likedYouReducer
                .reduce(into: &state.likedYou, action: likedYouAction)
                .map(NCReducer.Action.likedYou)
            
        case .mutuals(let mutualsAction):
            return mutualsReducer
                .reduce(into: &state.mutuals, action: mutualsAction)
                .map(NCReducer.Action.mutuals)
        }
    }
    
    public struct State: Equatable {
        var likedYou: LikedYouReducer.State
        var mutuals: MutualsReducer.State
    }
    
    public enum Action: Equatable {
        case likedYou(LikedYouReducer.Action)
        case mutuals(MutualsReducer.Action)
    }
}

extension NCReducer.Action: CasePathable {
    public struct AllCasePaths {
        public var likedYou: AnyCasePath<NCReducer.Action, LikedYouReducer.Action> {
            AnyCasePath(
                embed: { .likedYou($0) },
                extract: {
                    if case let .likedYou(value) = $0 { return value }
                    return nil
                }
            )
        }
        public var mutuals: AnyCasePath<NCReducer.Action, MutualsReducer.Action> {
            AnyCasePath(
                embed: { .mutuals($0) },
                extract: {
                    if case let .mutuals(value) = $0 { return value }
                    return nil
                }
            )
        }
    }
    public static var allCasePaths: AllCasePaths { AllCasePaths() }
}
