import ComposableArchitecture
import Foundation

public struct NCReducer: Reducer, Sendable {
    @Dependency(\.realtimeEventsService) var realtimeEventsService
    @Dependency(\.ncStateStore) var ncStateStore
    @Dependency(\.continuousClock) var clock
    
    private let likedYouReducer = LikedYouReducer()
    private let mutualsReducer = MutualsReducer()
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .merge(
                .run { _ in
                    await realtimeEventsService.startRandomInserts()
                }
                    .cancellable(id: CancelID.generator),
                .run { send in
                    for await event in self.realtimeEventsService.events() {
                        switch event {
                        case .likedYouInserted(let item):
                            await send(.likedYou(.newLikeItemReceived(item)))
                        case .mutualMatch(let item):
                            await send(.showMutualMatchNotification(item))
                        }
                    }
                }.cancellable(id: CancelID.realtime)
            )
            
        case .likedYou(.likeConfirmed(let item)):
            return .merge(
                .send(.showMutualMatchNotification(item)),
                .run { send in
                    try await clock.sleep(for: .seconds(10))
                    await send(.notificationDismiss)
                }
                    .cancellable(id: CancelID.notification, cancelInFlight: true),
                .send(.mutuals(.addMutual(item)))
                )
            
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
            
            let endDate = Date().addingTimeInterval(120)
            
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
            
        case .showMutualMatchNotification(let item):
            state.mutualMatchBanner = item.userName
            return .none
         
        case .notificationDismiss:
            state.mutualMatchBanner = nil
            return .none
            
        case .tapMutualMatchNotification:
            state.mutualMatchBanner = nil
            return .send(.tabSelected(.mutuals))
            
        case .tabSelected(let tab):
            state.selectedTab = tab
            if tab == .likedYou {
                return .send(.likedYou(.resetUnreadItemsCount))
            }
            return .none
            
        case .onDismiss:
            return
                .merge(
                    .cancel(id: ClockID.cancel),
                    .cancel(id: CancelID.generator),
                    .cancel(id: CancelID.realtime),
                    .cancel(id: CancelID.notification)
                )
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
        
        var mutualMatchBanner: String? = nil
        var selectedTab: Tabs = .likedYou
        
    }
    
    public enum Action: Equatable {
        case onAppear
        case onDismiss
        case likedYou(LikedYouReducer.Action)
        case mutuals(MutualsReducer.Action)
        
        case unblurAllTapped
        case unblurTimerExpired
        case appBecameActive
        
        case timerTick(Date)
        
        case showMutualMatchNotification(LikeItem)
        case notificationDismiss
        case tapMutualMatchNotification
        case tabSelected(Tabs)
    }
    
    enum BlurPolicy: Equatable {
        case alwaysBlurred
        case alwaysUnblurred
        case unblurAfterDelay(TimeInterval)
    }
    
    public enum Tabs: Int {
        case likedYou
        case mutuals
    }
    
    private enum ClockID: Hashable {
        case cancel
        case debounce
    }
    
    private enum CancelID: Hashable {
        case realtime
        case generator
        case notification
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

extension NCReducer.State {
    var likedYouBadgeCount: Int {
        likedYou.unreadItemsCount
    }
}
