import SwiftUI
import ComposableArchitecture

public struct LikedYouScreen: View {
    let store: StoreOf<LikedYouReducer>
    
    public init(store: StoreOf<LikedYouReducer>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GridView(
                items: viewStore.items,
                onLoadMore: {
                    viewStore.send(.loadNextPage)
                },
                onSkip: { id in
                    viewStore.send(.skip(id: id))
                },
                onLike: { id in
                    viewStore.send(.likeTapped(id: id))
                },
                onScrolledToTop: {
                    viewStore.send(.resetUnreadItemsCount)
                }
            )
            .task {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
            }
        }
    }
}


#Preview {
    LikedYouScreen(
        store: Store(
            initialState: LikedYouReducer.State()
        ) {
            LikedYouReducer()
        }
    )
}
