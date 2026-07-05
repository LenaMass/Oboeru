import SwiftUI

struct StudyView: View {
    
    @State private var isFlipped = false
    @State private var degree: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Spacing.xl) {
                    progressBar
                    flashCard
                    actionButtons
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
            }
            .navigationTitle("Study")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
            
        }
    }
    
    var progressBar: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack {
                Text("Card 1 of 10")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                Spacer()
                Text("0 done")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.sageGreen)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.border)
                        .frame(height: 7)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.vermillion)
                        .frame(width: geo.size.width * 0.1,
                               height: 7)
                }
            }
            .frame(height: 9)
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
            
            SealStamp(text: "N5")
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Spacer()
            
            Text("猫")
                .font(AppTheme.Typography.kanjiDisplay)
                .foregroundStyle(AppTheme.Colors.primaryText)
            
            Spacer()
            
            Text("tap to reveal")
                .font(AppTheme.Typography.cardHint)
                .foregroundStyle(AppTheme.Colors.vermillion)
                .padding(.bottom, AppTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        .padding(AppTheme.Spacing.lg)
        .oboeruCard()
    }
    
    var cardBack: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            Text("猫")
                .font(.system(size: 48, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.Colors.primaryText)
            
            Text("ねこ")
                .font(AppTheme.Typography.kanaReading)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            
            Rectangle()
                .fill(AppTheme.Colors.border)
                .frame(height: 0.5)
                .padding(.horizontal, AppTheme.Spacing.xl)
            
            Text("Cat")
                .font(AppTheme.Typography.meaning)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .fontWeight(.medium)
            
            Text("A small domesticated carnivorous mammal")
                .font(AppTheme.Typography.example)
                .foregroundStyle(AppTheme.Colors.secondaryText)
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
    
    func flipCard() {
        withAnimation(AppTheme.Animation.cardFlip) {
            degree += 180
            isFlipped.toggle()
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
    StudyView()
}
