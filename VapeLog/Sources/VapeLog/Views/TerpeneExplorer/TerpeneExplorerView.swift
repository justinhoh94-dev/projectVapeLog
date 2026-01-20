import SwiftUI

/// Educational content about terpenes and their effects
struct TerpeneExplorerView: View {
    private let terpenes = Terpene.allTerpenes

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection

                    ForEach(terpenes) { terpene in
                        TerpeneCard(terpene: terpene)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Terpene Explorer")
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(red: 0.10, green: 0.24, blue: 0.20),
                    Color(red: 0.04, green: 0.09, blue: 0.15)
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Understanding Terpenes")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Terpenes are aromatic compounds found in cannabis that influence its effects, aroma, and therapeutic benefits. Learn how each one affects your experience.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct TerpeneCard: View {
    let terpene: Terpene

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: terpene.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(terpene.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(terpene.aroma)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }

            Text(terpene.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))

            if !terpene.effects.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Common Effects:")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))

                    FlowLayout(spacing: 8) {
                        ForEach(terpene.effects, id: \.self) { effect in
                            Text(effect)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                )
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Flow Layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        TerpeneExplorerView()
    }
}
