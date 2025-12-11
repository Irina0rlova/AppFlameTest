import SwiftUI

public struct LikedYouScreen: View {
    @StateObject private var viewModel: LikedYouViewModel
    
    public init(repository: LikeYouRepository<LikeYouNetworkApi, LikeLocalApi>) {
        _viewModel = StateObject(wrappedValue: LikedYouViewModel(repository: repository))
    }
    
    public var body: some View {
        GridView(items: viewModel.items)
            .task {
                await viewModel.fetchData()
            }
    }
}


#Preview {
    LikedYouScreen(repository: LikeYouRepository<LikeYouNetworkApi, LikeLocalApi>(api: LikeYouNetworkApi(), localApi: LikeLocalApi()))
}
