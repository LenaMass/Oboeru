import SwiftUI

@main
struct OboeeruApp: App {
    
    let persistence = PersistenceController.shared
    @StateObject private var deckViewModel = DailyDeckViewModel()
    @StateObject private var libraryViewModel = LibraryViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                deckViewModel: deckViewModel,
                libraryViewModel: libraryViewModel
            )
            .environment(\.managedObjectContext,
                          persistence.context)
        }
    }
}
