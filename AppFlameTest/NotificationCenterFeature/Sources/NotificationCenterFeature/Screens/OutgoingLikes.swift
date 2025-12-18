import SwiftUI
import ComposableArchitecture

public struct OutgoingLikesScreen: View {
    let store: StoreOf<NCReducer>
    
    @State private var selectedTab = 0
    
    public init() {
        self.store = Store(
            initialState: NCReducer.State(
                likedYou: LikedYouReducer.State(),
                mutuals: MutualsReducer.State())
        ) {
            NCReducer()
        }
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 } ) { viewStore in
            ZStack(alignment: .bottom) {
                ZStack {
                    VStack {
                        buttonsView()
                        Spacer()
                        selectedTabView()
                        Spacer()
                    }
                    
                    if viewStore.blurPolicy == .alwaysBlurred {
                        overlayView(
                            onButtonTap: {
                                store.send(.unblurAllTapped)
                            }
                        )
                    }
                }
                
                if let endDate = viewStore.unblurEndDate {
                    UnblurTimerView(endDate: endDate)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: endDate)
                        .zIndex(1)
                }
            }
            .onAppear {
                store.send(.appBecameActive)
            }
        }
    }
    
    private func buttonsView() -> some View {
        WithViewStore(store, observe: \.likedYou.unreadItemsCount) { viewStore in
            HStack {
                Button(action: {
                    selectedTab = 0
                    store.send(.likedYou(.resetUnreadItemsCount))
                }) {
                    ZStack(alignment: .topTrailing) {
                        Text("Liked You")
                            .padding()
                            .background(selectedTab == 0 ? Color.black : Color.clear)
                            .foregroundColor(selectedTab == 0 ? .white : .black)
                            .cornerRadius(10)
                        
                        if viewStore.state > 0 {
                            badgeView(count: viewStore.state)
                                .offset(x: 8, y: -8)
                        }
                    }
                }
                
                Button(action: {
                    selectedTab = 1
                }) {
                    Text("Mutuals")
                        .padding()
                        .background(selectedTab == 1 ? Color.black : Color.clear)
                        .foregroundColor(selectedTab == 1 ? .white : .black)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    private func selectedTabView() -> AnyView {
        if selectedTab == 0 {
            return AnyView(
                LikedYouScreen(
                    store: store.scope(
                        state: \.likedYou,
                        action: \.likedYou
                    )
                )
            )
        } else {
            return AnyView(
                MutualsScreen(
                    store: store.scope(
                        state: \.mutuals,
                        action: \.mutuals
                    )
                )
            )
        }
    }
    
    private func overlayView(onButtonTap: @escaping () -> Void) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            Button(action: onButtonTap) {
                Text("Unblur All")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
        }
    }
    
    private func badgeView(count: Int) -> some View {
        Text("\(count)")
            .font(.caption2)
            .foregroundColor(.white)
            .padding(6)
            .background(Color.red)
            .clipShape(Circle())
            .minimumScaleFactor(0.5)
    }
}

#Preview {
    OutgoingLikesScreen()
}
