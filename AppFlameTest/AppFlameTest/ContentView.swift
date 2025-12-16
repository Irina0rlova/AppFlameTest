import SwiftUI
import NotificationCenterFeature

struct ContentView: View {
    @State private var selectedTab = 3 // Start with the 4th tab (zero-based)
    @State private var notificationCount = 5 // Example notification count
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Hilly")
                .tabItem {
                    Image("hilly")
                }
                .tag(0)
            Text("Chat")
                .tabItem {
                    Image("chat")
                }
                .tag(1)
            Text("Square")
                .tabItem {
                    Image("square")
                }
                .tag(2)
            NavigationStack {
                //NotificationCenterFeature().makeModuleView()
                LikesView()
                    .navigationTitle("Likes")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image("heart")
            }
            .tag(3)
            .badge(notificationCount)
            Text("Profile")
                .tabItem {
                    Image("person")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
}
