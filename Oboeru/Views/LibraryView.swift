import SwiftUI
import CoreData

struct LibraryView: View {
    
    @ObservedObject var viewModel: LibraryViewModel
    @State private var selectedFilter: CardFilter = .all
    
    enum CardFilter: String, CaseIterable {
        case all = "All"
        case due = "Review Now"
        case known = "Mastered"
    }
    
    var filteredCards: [FlashCard] {
        switch selectedFilter {
        case .all: return viewModel.allCards
        case .due: return viewModel.dueCards
        case .known: return viewModel.allCards.filter { $0.isKnown }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    filterPicker
                    
                    if filteredCards.isEmpty {
                        emptyState
                    } else {
                        cardList
                    }
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.light)
            .onAppear {
                viewModel.fetchCards()
            }
        }
    }
    
    var filterPicker: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(CardFilter.allCases, id: \.self) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    VStack(spacing: 2) {
                        Text(filter.rawValue)
                            .font(AppTheme.Typography.caption)
                            .fontWeight(
                                selectedFilter == filter ? .semibold : .regular
                            )
                        Text("\(countFor(filter))")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(selectedFilter == filter ?
                                     AppTheme.Colors.vermillion :
                                     AppTheme.Colors.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        selectedFilter == filter ?
                        AppTheme.Colors.cardSurface : Color.clear
                    )
                    .clipShape(RoundedRectangle(
                        cornerRadius: AppTheme.Radius.badge
                    ))
                }
            }
        }
        .padding(AppTheme.Spacing.xs)
        .background(AppTheme.Colors.border.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
    }
    
    var cardList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(filteredCards) { card in
                    LibraryCardRow(
                        word: card.word,
                        reading: card.reading,
                        meaning: card.meaning,
                        daysUntilReview: daysUntilReview(card),
                        isKnown: card.isKnown
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }
    
    var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()
            
            Text("本")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.Colors.border)
            
            switch selectedFilter {
            case .all:
                Text("No cards yet")
                    .font(AppTheme.Typography.meaning)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Text("Complete today's deck to start building your library")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .multilineTextAlignment(.center)
            case .due:
                Text("All caught up!")
                    .font(AppTheme.Typography.meaning)
                    .foregroundStyle(AppTheme.Colors.sageGreen)
                Text("No cards due for review right now.\nCome back tomorrow 🌸")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .multilineTextAlignment(.center)
            case .known:
                Text("No mastered cards yet")
                    .font(AppTheme.Typography.meaning)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Text("Study each word 5 times to master it")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }
    
    func countFor(_ filter: CardFilter) -> Int {
        switch filter {
        case .all: return viewModel.allCards.count
        case .due: return viewModel.dueCards.count
        case .known: return viewModel.allCards.filter { $0.isKnown }.count
        }
    }
    
    func daysUntilReview(_ card: FlashCard) -> Int {
        let days = Calendar.current.dateComponents(
            [.day], from: Date(), to: card.nextReviewDate
        ).day ?? 0
        return max(0, days)
    }
}

#Preview {
    LibraryView(viewModel: LibraryViewModel())
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.context
        )
}
