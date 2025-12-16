import SwiftUI

public struct CardView: View {
    let item: LikeItem
    let onSkip: (_ id: UUID) -> Void
    
    public init(
        item: LikeItem,
        onSkip: @escaping (_ id: UUID) -> Void
    ) {
        self.item = item
        self.onSkip = onSkip
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: item.avatarURL) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.8)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Color.gray.opacity(0.2)
                @unknown default:
                    Color.gray
                }
            }
            .frame(height: 200)
            .clipped()
            .overlay(
                Group {
                    if item.isBlurred {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    }
                }
            )
            
            ZStack(alignment: .bottomLeading) {
                Text(item.userName)
                    .font(.headline)
                    .padding(8)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                
                VStack(spacing: 8) {
                    Button(action: { }) {
                        Image(systemName: "heart.fill")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.pink.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(item.isReadOnly)
                    .opacity(item.isReadOnly ? 0.5 : 1.0)
                    .grayscale(item.isReadOnly ? 1.0 : 0.0)
                    
                    Button(action: { onSkip(item.id) }) {
                        Image(systemName: "xmark")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.25))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(item.isReadOnly)
                    .opacity(item.isReadOnly ? 0.5 : 1.0)
                    .grayscale(item.isReadOnly ? 1.0 : 0.0)
                }
                .padding([.trailing, .bottom], 12)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            }
        }
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

#Preview {
    CardView(item: LikeItem(
        id: UUID(),
        userName: "User 1",
        avatarURL: URL(string: "https://randomuser.me/api/portraits/men/1.jpg"),
        isBlurred: false,
        isReadOnly: true
    ), onSkip: { id in } )
}
