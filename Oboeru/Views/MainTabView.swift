import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab = 0
    @ObservedObject var deckViewModel: DailyDeckViewModel
    @ObservedObject var libraryViewModel: LibraryViewModel
    
    init(deckViewModel: DailyDeckViewModel,
         libraryViewModel: LibraryViewModel) {
        self.deckViewModel = deckViewModel
        self.libraryViewModel = libraryViewModel
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(
            red: 0.929, green: 0.910, blue: 0.878, alpha: 1.0
        )
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                selectedTab: $selectedTab,
                deckViewModel: deckViewModel,
                libraryViewModel: libraryViewModel
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            StudyTabView(libraryViewModel: libraryViewModel)
                .tabItem {
                    Label("Study", systemImage: "rectangle.on.rectangle.fill")
                }
                .tag(2)
            
            LibraryView(viewModel: libraryViewModel)
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
                .tag(3)
        }
        .tint(AppTheme.Colors.vermillion)
    }
}

#Preview {
    MainTabView(
        deckViewModel: DailyDeckViewModel(),
        libraryViewModel: LibraryViewModel()
    )
}
