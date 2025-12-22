import SwiftUI

struct UnblurTimerView: View {
    let endDate: Date
    
    private var remainingText: String {
        let remaining = max(0, Int(endDate.timeIntervalSinceNow))
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            HStack(spacing: 8) {
                Image(systemName: "eye.slash")
                    .foregroundColor(.white)
                
                Text("Unblur ends in \(remainingText)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.85))
            .cornerRadius(20)
            .shadow(radius: 4)
        }
    }
}
