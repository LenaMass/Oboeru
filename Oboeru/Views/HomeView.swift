import SwiftUI

struct HomeView: View {
    
    @StateObject private var deckViewModel = DailyDeckViewModel()
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "おはよう"
        } else if hour < 18 {
            return "こんにちは"
        } else {
            return "こんばんは"
        }
    }
    
    var greetingSubtitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good Morning"
        } else if hour < 18 {
            return "Good Afternoon"
        } else {
            return "Good Evening"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    headerSection
                    dailyDeckSection
                    actionButtons
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(
                Image("HomePageBG")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.4)
                    .ignoresSafeArea()
            )
            .background(AppTheme.Colors.background.ignoresSafeArea())
        }
    }
    
    var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(greeting)
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(greetingSubtitle)
                    .font(AppTheme.Typography.kanaReading)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            SealStamp(text: "覚える")
        }
    }
    
    var dailyDeckSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Today's Deck")
                    .font(AppTheme.Typography.sectionHeader)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
                Text("今日")
                    .font(.system(size: 16,
                                 weight: .bold,
                                 design: .serif))
                    .foregroundStyle(AppTheme.Colors.vermillion)
            }
            
            if deckViewModel.isLoading {
                loadingCard
            } else if deckViewModel.isCompleted {
                completedCard
            } else if let error = deckViewModel.errorMessage {
                errorCard(message: error)
            } else {
                deckCard
            }
        }
    }
    
    var deckCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("\(deckViewModel.todaysDeck.count) words ready")
                        .font(AppTheme.Typography.meaning)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                    
                    Text("5 vocabulary · 5 kanji words")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("続")
                        .font(.system(size: 32,
                                     weight: .bold,
                                     design: .serif))
                        .foregroundStyle(AppTheme.Colors.vermillion)
                }
            }
            
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(0..<10, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < deckViewModel.todaysDeck.count ?
                              AppTheme.Colors.vermillion :
                              AppTheme.Colors.border)
                        .frame(height: 4)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .oboeruCard()
    }
    
    var loadingCard: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .tint(AppTheme.Colors.vermillion)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Preparing your deck...")
                    .font(AppTheme.Typography.meaning)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                
                Text("Fetching today's words from Jisho")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
        .oboeruCard()
    }
    
    var completedCard: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("今日は終わり")
                .font(.system(size: 28,
                             weight: .bold,
                             design: .serif))
                .foregroundStyle(AppTheme.Colors.sageGreen)
            
            Text("You completed today's deck")
                .font(AppTheme.Typography.meaning)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            
            Text("Come back tomorrow for 10 new words")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.xl)
        .oboeruCard()
    }
    
    func errorCard(message: String) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 32))
                .foregroundStyle(AppTheme.Colors.vermillion)
            
            Text(message)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)
            
            Button {
                deckViewModel.generateNewDeck()
            } label: {
                Text("Try Again")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.vermillion)
                    .clipShape(RoundedRectangle(
                        cornerRadius: AppTheme.Radius.button
                    ))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
        .oboeruCard()
    }
    
    var actionButtons: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button {
            } label: {
                HStack {
                    Image(systemName: "rectangle.on.rectangle")
                        .font(.system(size: 18, weight: .medium))
                    Text(deckViewModel.isCompleted ?
                         "Review Saved Cards" : "Start Today's Deck")
                        .font(AppTheme.Typography.meaning)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(deckViewModel.isCompleted ?
                            AppTheme.Colors.sageGreen :
                            AppTheme.Colors.vermillion)
                .clipShape(RoundedRectangle(
                    cornerRadius: AppTheme.Radius.button
                ))
            }
            
            Button {
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                    Text("Search Words")
                        .font(AppTheme.Typography.meaning)
                        .fontWeight(.medium)
                }
                .foregroundStyle(AppTheme.Colors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.Colors.cardSurface)
                .clipShape(RoundedRectangle(
                    cornerRadius: AppTheme.Radius.button
                ))
                .overlay(
                    RoundedRectangle(
                        cornerRadius: AppTheme.Radius.button
                    )
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    HomeView()
}
