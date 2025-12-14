import SwiftUI
import ComposableArchitecture

public struct MutualsScreen: View {
    let store: StoreOf<MutualsReducer>
    
    public init(store: StoreOf<MutualsReducer>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GridView(
                items: viewStore.items,
                onLoadMore: {}
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
            .overlay {
                if viewStore.items.isEmpty {
                    Text("No Mutuals")
                }
            }
        }
    }
}

#Preview {
    MutualsScreen(
        store: Store(
            initialState: MutualsReducer.State()
        ) {
            MutualsReducer()
        }
    )
}
