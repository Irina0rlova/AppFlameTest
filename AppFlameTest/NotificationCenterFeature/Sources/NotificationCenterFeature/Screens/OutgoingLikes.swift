import SwiftUI
import ComposableArchitecture

public struct OutgoingLikesScreen: View {
    @State private var selectedTab = 0
    
    public init() { }
    
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
                    store: Store(
                        initialState: LikedYouReducer.State()
                    ) {
                        LikedYouReducer()
                    }
                )
            } else {
                MutualsScreen(
                    store: Store(
                        initialState: MutualsReducer.State()
                    ) {
                        MutualsReducer()
                    }
                )
            }
            
            Spacer()
        }
    }
}

#Preview {
    OutgoingLikesScreen()
}
