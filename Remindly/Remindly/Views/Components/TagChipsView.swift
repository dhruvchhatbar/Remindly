import SwiftUI

struct TagChipsView: View {
    let allTags: [String]
    @Binding var selected: Set<String>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(allTags, id: \.self) { tag in
                    Button {
                        toggle(tag)
                    } label: {
                        HStack(spacing: 6) {
                            Text(tag)
                            if selected.contains(tag) {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                            }
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            selected.contains(tag) ?
                            LinearGradient(
                                colors: [AppTheme.brand, AppTheme.brandSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [
                                    Color.gray.opacity(0.5),
                                    Color.gray.opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(selected.contains(tag) ? .white : .primary)
                        .clipShape(Capsule())
                        .shadow(
                            color: selected.contains(tag) ? AppTheme.brand.opacity(0.4) : Color.clear,
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                    }
                    .buttonStyle(.plain)
                }
                if !selected.isEmpty {
                    Button("Clear") { selected.removeAll() }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.15))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func toggle(_ tag: String) {
        if selected.contains(tag) { selected.remove(tag) } else { selected.insert(tag) }
    }
}

#Preview {
    TagChipsView(allTags: ["swift", "ios", "work"], selected: .constant(["swift"]))
        .padding()
}


