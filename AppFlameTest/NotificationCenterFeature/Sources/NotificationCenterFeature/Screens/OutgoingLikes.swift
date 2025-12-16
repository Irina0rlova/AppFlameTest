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
        VStack {
            HStack {
                Button(action: {
                    selectedTab = 0
                }) {
                    Text("Liked You")
                        .padding()
                        .background(selectedTab == 0 ? Color.blue : Color.clear)
                        .foregroundColor(selectedTab == 0 ? .white : .black)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedTab = 1
                }) {
                    Text("Mutuals")
                        .padding()
                        .background(selectedTab == 1 ? Color.blue : Color.clear)
                        .foregroundColor(selectedTab == 1 ? .white : .black)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            Spacer()
            
            if selectedTab == 0 {
                LikedYouScreen(
                    store: store.scope(
                        state: \.likedYou,
                        action: \.likedYou
                    )
                )
            } else {
                MutualsScreen(
                    store: store.scope(
                        state: \.mutuals,
                        action: \.mutuals
                    )
                )
            }
            
            Spacer()
        }
    }
}

#Preview {
    OutgoingLikesScreen()
}
