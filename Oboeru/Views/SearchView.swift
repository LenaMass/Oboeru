import SwiftUI

struct SearchView: View {
    
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchBar
                    
                    if isSearching {
                        loadingView
                    } else if searchText.isEmpty {
                        emptyPrompt
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
        var searchBar: some View {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                
                TextField("Search in Japanese or English...",
                          text: $searchText)
                .font(AppTheme.Typography.meaning)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .submitLabel(.search)
                .onSubmit {
                    isSearching = true
                }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        isSearching = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.Colors.tertiaryText)
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        
        var emptyPrompt: some View {
            VStack(spacing: AppTheme.Spacing.md) {
                Spacer()
                
//                Text("探す")
//                    .font(.system(size: 64, weight: .bold, design: .serif))
//                    .foregroundStyle(AppTheme.Colors.border)
//                
                Text("Search any Japanese word\nor English meaning")
                    .font(AppTheme.Typography.meaning)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .multilineTextAlignment(.center)
                
//                 Spacer()
                .padding(.top,-400)
            }
        }
        
        var loadingView: some View {
            VStack(spacing: AppTheme.Spacing.md) {
                Spacer()
                
                ProgressView()
                    .tint(AppTheme.Colors.vermillion)
                
                Text("Searching...")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                
                Spacer()
            }
        }
        
        var resultsList: some View {
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.md) {
                    ForEach(0..<5, id: \.self) { _ in
                        SearchResultCard(
                            word: "猫",
                            reading: "ねこ",
                            meaning: "Cat",
                            jlptLevel: "N5"
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
            }
        }
    }
#Preview {
    SearchView()
}
