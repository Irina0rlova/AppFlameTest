import SwiftUI
import ComposableArchitecture

public struct OutgoingLikesScreen: View {
    let store: StoreOf<NCReducer>
    
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
                        buttonsView(
                            badgeCount: viewStore.likedYouBadgeCount,
                            selectedTab: viewStore.state.selectedTab.rawValue,
                            likedYouTapped: { viewStore.send(.tabSelected(NCReducer.Tabs.likedYou)) },
                            mutualsTapped: { viewStore.send(.tabSelected(NCReducer.Tabs.mutuals)) }
                        )
                        Spacer()
                        selectedTabView(selectedTab: viewStore.state.selectedTab.rawValue)
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
                
                if let banner = viewStore.mutualMatchBanner {
                    bannerView(banner) {
                        store.send(.tapMutualMatchNotification)
                    }
                }
            }
            .onAppear {
                store.send(.appBecameActive)
            }
            .task {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                store.send(.onDismiss)
            }
        }
    }
    
    private func buttonsView(
        badgeCount: Int,
        selectedTab: Int,
        likedYouTapped: @escaping () -> Void,
        mutualsTapped: @escaping () -> Void
    ) -> some View {
            HStack {
                Button(action: {
                    likedYouTapped()
                }) {
                    ZStack(alignment: .topTrailing) {
                        Text("Liked You")
                            .padding()
                            .background(selectedTab == 0 ? Color.black : Color.clear)
                            .foregroundColor(selectedTab == 0 ? .white : .black)
                            .cornerRadius(10)
                        
                        if badgeCount > 0 {
                            badgeView(count: badgeCount)
                                .offset(x: 8, y: -8)
                        }
                    }
                }
                
                Button(action: {
                    mutualsTapped()
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
    
    private func bannerView(_ banner: String?, onTap: @escaping () -> Void) -> some View {
        VStack {
            Text("🎉 Mutual Match: \(banner)!")
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
                .onTapGesture {
                    onTap()
                }
            Spacer()
        }
        .padding()
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: banner)
    }
    
    private func selectedTabView(selectedTab: Int) -> AnyView {
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
