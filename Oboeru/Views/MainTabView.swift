import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            StudyView()
                .tabItem {
                    Label("Study", systemImage: "rectangle.on.rectangle.fill")
                }

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
        }
        .tint(AppTheme.Colors.vermillion)
    }
}

#Preview {
    MainTabView()
}
