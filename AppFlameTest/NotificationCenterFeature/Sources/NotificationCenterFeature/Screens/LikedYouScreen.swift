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
                }
            )
            .task {
                viewStore.send(.onAppear)
            }
            .overlay {
                if viewStore.isLoading {
                    ProgressView()
                }
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
