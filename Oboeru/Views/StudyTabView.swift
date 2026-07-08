import SwiftUI

struct StudyTabView: View {
    
    @ObservedObject var libraryViewModel: LibraryViewModel
    @State private var showingStudy = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Spacing.xl) {
                    Spacer()
                    
                    Text("学習")
                        .font(.system(size: 64,
                                     weight: .bold,
                                     design: .serif))
                        .foregroundStyle(AppTheme.Colors.vermillion)
                    
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("Review Session")
                            .font(AppTheme.Typography.kanaReading)
                            .foregroundStyle(AppTheme.Colors.primaryText)
                        
                        Text("\(libraryViewModel.dueCount) cards due for review")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.tertiaryText)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingStudy = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.on.rectangle")
                                .font(.system(size: 18, weight: .medium))
                            Text(libraryViewModel.dueCount > 0 ?
                                 "Start Review (\(libraryViewModel.dueCount))" :
                                 "No cards due")
                                .font(AppTheme.Typography.meaning)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(libraryViewModel.dueCount > 0 ?
                                    AppTheme.Colors.vermillion :
                                    AppTheme.Colors.border)
                        .clipShape(RoundedRectangle(
                            cornerRadius: AppTheme.Radius.button
                        ))
                    }
                    .disabled(libraryViewModel.dueCount == 0)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .navigationTitle("Study")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.light)
            .onAppear {
                libraryViewModel.fetchCards()
            }
            .sheet(isPresented: $showingStudy,
                   onDismiss: { libraryViewModel.fetchCards() }) {
                StudyView(deck: libraryViewModel.dueCards)
            }
        }
    }
}

#Preview {
    StudyTabView(libraryViewModel: LibraryViewModel())
}
