import SwiftUI

struct StudyView: View {
    
    let deck: [FlashCard]
    var onComplete: (() -> Void)?
    
    @StateObject private var viewModel: StudyViewModel
    @State private var isFlipped = false
    @State private var degree: Double = 0
    @Environment(\.dismiss) var dismiss
    
    init(deck: [FlashCard], onComplete: (() -> Void)? = nil) {
        self.deck = deck
        self.onComplete = onComplete
        _viewModel = StateObject(
            wrappedValue: StudyViewModel(deck: deck)
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                if viewModel.isSessionComplete {
                    completionView
                } else {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        progressBar
                        flashCard
                        actionButtons
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.lg)
                }
            }
            .navigationTitle("Study")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
        }
    }
    
    var progressBar: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack {
                Text("Card \(viewModel.currentIndex + 1) of \(viewModel.totalCards)")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                Spacer()
                Text("\(viewModel.currentIndex) done")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.sageGreen)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.border)
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.vermillion)
                        .frame(
                            width: geo.size.width * viewModel.progress,
                            height: 4
                        )
                        .animation(AppTheme.Animation.spring,
                                   value: viewModel.progress)
                }
            }
            .frame(height: 4)
        }
    }
    
    var flashCard: some View {
        ZStack {
            cardFront
                .opacity(isFlipped ? 0 : 1)
            
            cardBack
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .rotation3DEffect(
            .degrees(degree),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            flipCard()
        }
    }
    
    var cardFront: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            HStack {
                Spacer()
                if let card = viewModel.currentCard {
                    SealStamp(text: card.jlptLevel)
                }
            }
            
            Spacer()
            
            Text(viewModel.currentCard?.word ?? "")
                .font(AppTheme.Typography.kanjiDisplay)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Text("tap to reveal")
                .font(AppTheme.Typography.cardHint)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .padding(.bottom, AppTheme.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        .padding(AppTheme.Spacing.lg)
        .oboeruCard()
    }
    
    var cardBack: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            Text(viewModel.currentCard?.word ?? "")
                .font(.system(size: 48, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text(viewModel.currentCard?.reading ?? "")
                .font(AppTheme.Typography.kanaReading)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            
            Rectangle()
                .fill(AppTheme.Colors.border)
                .frame(height: 0.5)
                .padding(.horizontal, AppTheme.Spacing.xl)
            
            Text(viewModel.currentCard?.meaning ?? "")
                .font(AppTheme.Typography.meaning)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .fontWeight(.medium)
                .minimumScaleFactor(0.7)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        .padding(AppTheme.Spacing.lg)
        .oboeruCard()
    }
    
    var actionButtons: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            Button {
                viewModel.markForgot()
                resetCard()
            } label: {
                VStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(AppTheme.Colors.vermillion)
                    Text("Forgot")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                }
            }
            
            Spacer()
            
            Button {
                resetCard()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 24))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            }
            
            Spacer()
            
            Button {
                viewModel.markKnown()
                resetCard()
            } label: {
                VStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(AppTheme.Colors.sageGreen)
                    Text("Got it")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
        .opacity(isFlipped ? 1 : 0)
        .animation(AppTheme.Animation.quick, value: isFlipped)
    }
    
    var completionView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            
            Text("完了")
                .font(.system(size: 72, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.Colors.vermillion)
            
            Text("Session Complete")
                .font(AppTheme.Typography.kanaReading)
                .foregroundStyle(AppTheme.Colors.primaryText)
            
            Text("You studied \(viewModel.totalCards) cards")
                .font(AppTheme.Typography.meaning)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            
            Spacer()
            
            Button {
                onComplete?()
                dismiss()
            } label: {
                Text("Back to Home")
                    .font(AppTheme.Typography.meaning)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.vermillion)
                    .clipShape(RoundedRectangle(
                        cornerRadius: AppTheme.Radius.button
                    ))
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }
    
    func flipCard() {
        withAnimation(AppTheme.Animation.cardFlip) {
            isFlipped.toggle()
            degree = isFlipped ? 180 : 0
        }
    }
    
    func resetCard() {
        withAnimation(AppTheme.Animation.cardFlip) {
            degree = 0
            isFlipped = false
        }
    }
}

#Preview {
    StudyView(deck: [
        FlashCard(word: "猫", reading: "ねこ",
                  meaning: "Cat", jlptLevel: "N5")
    ])
}
