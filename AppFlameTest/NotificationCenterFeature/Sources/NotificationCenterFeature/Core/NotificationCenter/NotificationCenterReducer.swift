import ComposableArchitecture
import Foundation

public struct NCReducer: Reducer {
    private let likedYouReducer = LikedYouReducer()
    private let mutualsReducer = MutualsReducer()
    private let ncStateStore = NCStateStore()
    
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
            
        case .unblurAllTapped:
            guard state.unblurEndDate == nil else {
                return .none
            }
            
            let endDate = Date().addingTimeInterval(15)
            
            state.unblurEndDate = endDate
            state.blurPolicy = .alwaysUnblurred
            
            ncStateStore.saveUnblurEndDate(endDate: endDate)
            
            return .merge(
                .send(.likedYou(.blur(isBlured: false))),
                startTimer()
            )
            
        case .unblurTimerExpired:
            state.unblurEndDate = nil
            state.blurPolicy = .alwaysBlurred
            
            ncStateStore.saveUnblurEndDate(endDate: state.unblurEndDate)
            
            return .merge(
                .cancel(id: ClockID.cancel),
                .send(.likedYou(.blur(isBlured: true)))
                )
            
        case .timerTick(let now):
            guard let endDate = state.unblurEndDate else {
                return .none
            }
            
            if now >= endDate {
                return .send(.unblurTimerExpired)
            }
            return .none
            
        case .appBecameActive:
            if let savedEndDate = ncStateStore.getUnblurEndDate() {
                state.unblurEndDate = savedEndDate
                
                if savedEndDate > Date() {
                    return startTimer()
                } else {
                    ncStateStore.saveUnblurEndDate(endDate: nil)
                    state.unblurEndDate = nil
                    return .cancel(id: ClockID.cancel)
                }
            }
            return .none
        }
    }
    
    private func startTimer() -> Effect<Action> {
        .run { send in
            while true {
                try await Task.sleep(for: .seconds(1))
                await send(.timerTick(Date()))
            }
        }
        .cancellable(id: ClockID.cancel, cancelInFlight: true)
    }

    public struct State: Equatable {
        var likedYou: LikedYouReducer.State
        var mutuals: MutualsReducer.State
        
        var blurPolicy: BlurPolicy = .alwaysBlurred
        var unblurEndDate: Date?
    }
    
    public enum Action: Equatable {
        case likedYou(LikedYouReducer.Action)
        case mutuals(MutualsReducer.Action)
        
        case unblurAllTapped
        case unblurTimerExpired
        case appBecameActive
        
        case timerTick(Date)
    }
    
    enum BlurPolicy: Equatable {
        case alwaysBlurred
        case alwaysUnblurred
        case unblurAfterDelay(TimeInterval)
    }
    
    private enum ClockID: Hashable {
        case cancel
        case debounce
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
