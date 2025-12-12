import Foundation
import SwiftUI

@MainActor
final class LikedYouViewModel: ObservableObject {
    private let repository: LikeYouRepository<LikeYouNetworkApi, LikeLocalApi>
    
    @Published var items: [LikeItem] = [] // need to be changed!!!!!
    @Published var isLoading: Bool = false
    
    init(repository: LikeYouRepository<LikeYouNetworkApi, LikeLocalApi>) {
        self.repository = repository
    }
    
    func fetchData() async {
        self.isLoading = true
        defer { self.isLoading = false } // Ensure this is set to false after fetching
        
        do {
            try await self.repository.load(page: 1, batchSize: 10)
        } catch {
            // handle error if needed
        }
        
        self.items = self.repository.getData() ?? []
    }
}

