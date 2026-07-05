import SwiftUI

struct SearchView: View {
    
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchBar
                    content
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.light)
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
                    viewModel.search(query: searchText)
                }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    viewModel.clearSearch()
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
    
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(message: error)
        } else if !viewModel.hasSearched {
            emptyPrompt
        } else if viewModel.results.isEmpty {
            noResultsView
        } else {
            resultsList
        }
    }
    
    var emptyPrompt: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()
            
            Text("探す")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.Colors.border)
            
            Text("Search any Japanese word\nor English meaning")
                .font(AppTheme.Typography.meaning)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)
            
            Spacer()
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
    
    var noResultsView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()
            
            Text("見つからない")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.Colors.border)
            
            Text("No results found for \"\(searchText)\"")
                .font(AppTheme.Typography.meaning)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    func errorView(message: String) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()
            
            Image(systemName: "wifi.slash")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.Colors.vermillion)
            
            Text(message)
                .font(AppTheme.Typography.meaning)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
            
            Button {
                viewModel.search(query: searchText)
            } label: {
                Text("Try Again")
                    .font(AppTheme.Typography.meaning)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.vermillion)
                    .clipShape(RoundedRectangle(
                        cornerRadius: AppTheme.Radius.button
                    ))
            }
            
            Spacer()
        }
    }
    
    var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(viewModel.results) { word in
                    SearchResultCard(
                        word: word.primaryWord,
                        reading: word.primaryReading,
                        meaning: word.primaryMeaning,
                        jlptLevel: word.jlptLevel
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
