import SwiftUI

struct FilterSheetView: View {
    let groups: [TagGroup]
    @Binding var selectedTags: Set<TagGroup>
    @Binding var selectedMonths: Set<Int>
    @Environment(\.presentationMode) var presentationMode // To dismiss the sheet

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("Filters")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top)

                Divider()
                    .background(Color.gray)

                // Tag Filter Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(groups, id: \.id) { tag in
                                Button(action: {
                                    toggleTagSelection(tag)
                                }) {
                                    Text(tag.name)
                                        .font(.custom("Bicyclette-Regular", size: 14))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(selectedTags.contains(tag) ? Color.orange : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedTags.contains(tag) ? .white : .orange)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Month Filter Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Months")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .padding(.horizontal)

                    // Wrap months dynamically
                    ScrollView {
                        WrapView(items: 1...12, id: \.self) { month in
                            Button(action: {
                                toggleMonthSelection(month)
                            }) {
                                Text(Calendar.current.monthSymbols[month - 1])
                                    .font(.custom("Bicyclette-Regular", size: 14))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(selectedMonths.contains(month) ? Color.orange : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedMonths.contains(month) ? .white : .orange)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()

                // Apply Filters Button
                Button("Apply Filters") {
                    presentationMode.wrappedValue.dismiss() // Dismiss the sheet
                }
                .font(.custom("Bicyclette-Bold", size: 18))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .background(Color.white)
        }
    }

    // MARK: - Helper Methods
    private func toggleTagSelection(_ tag: TagGroup) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    private func toggleMonthSelection(_ month: Int) {
        if selectedMonths.contains(month) {
            selectedMonths.remove(month)
        } else {
            selectedMonths.insert(month)
        }
    }
}

// MARK: - WrapView
struct WrapView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    @State private var totalHeight = CGFloat.zero // Tracks height of the entire view

    init(items: Data, id: KeyPath<Data.Element, Data.Element>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight) // Set the height dynamically
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                self.content(item)
                    .padding(4)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0 // Reset width
                            height -= dimension.height // Move to the next line
                        }
                        let result = width
                        if item == self.items.last! {
                            width = 0 // Reset for the next item
                        } else {
                            width -= dimension.width // Accumulate width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == self.items.last! {
                            height = 0 // Reset for the next item
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewHeightPreferenceKey.self, value: geometry.size.height)
        }
        .onPreferenceChange(ViewHeightPreferenceKey.self) { binding.wrappedValue = $0 }
    }
}

struct ViewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
