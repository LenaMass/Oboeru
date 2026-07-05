import SwiftUI

struct LibraryView: View {
    
    @State private var selectedFilter: CardFilter = .all
    
    enum CardFilter: String, CaseIterable {
        case all = "All"
        case due = "Due"
        case known = "Known"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    filterPicker
                    cardList
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.light)
        }
    }
    
    var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(CardFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
    }
    
    var cardList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(0..<8, id: \.self) { _ in
                    LibraryCardRow(
                        word: "猫",
                        reading: "ねこ",
                        meaning: "Cat",
                        daysUntilReview: 2,
                        isKnown: false
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }
}

#Preview {
    LibraryView()
}
