import SwiftUI

public struct GridView: View {
    let items: [LikeItem]
    
    private var columns: [GridItem] {
        let screenWidth = UIScreen.main.bounds.width
        let columnCount: Int
        
        if screenWidth > 600 {
            columnCount = 3
        } else if screenWidth > 400 {
            columnCount = 2
        } else {
            columnCount = 1
        }
        
        return Array(repeating: GridItem(.flexible(), spacing: 20), count: columnCount)
    }
    
    private let gridSpacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 5
    private let verticalPadding: CGFloat = 8
    
    public init(items: [LikeItem]) {
        self.items = items
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(items) { item in
                    CardView(item: item)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
    }
}
