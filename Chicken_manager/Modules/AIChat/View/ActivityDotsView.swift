import SwiftUI

struct ActivityDotsView: View {
    
    private let dotCount = 3
    private let animationStep: TimeInterval = 0.25
    
    var body: some View {
        TimelineView(.animation) { context in
            
            let index = activeIndex(at: context.date)
            
            HStack(spacing: 6) {
                ForEach(0..<dotCount, id: \.self) { position in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(.white.opacity(position == index ? 1 : 0.25))
                        .animation(.easeInOut(duration: 0.2), value: index)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.appLightBrown.opacity(0.3))
        .cornerRadius(20)
    }
    
    private func activeIndex(at date: Date) -> Int {
        let phase = date.timeIntervalSinceReferenceDate / animationStep
        return Int(phase) % dotCount
    }
}
