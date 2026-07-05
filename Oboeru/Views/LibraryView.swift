import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                Text("Library")
                    .font(AppTheme.Typography.meaning)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LibraryView()
}
