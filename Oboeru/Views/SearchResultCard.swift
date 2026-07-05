import SwiftUI

struct SearchResultCard: View {
    let word: String
    let reading: String
    let meaning: String
    let jlptLevel: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack(alignment: .firstTextBaseline,
                       spacing: AppTheme.Spacing.sm) {
                    Text(word)
                        .font(.system(size: 28,
                                     weight: .bold,
                                     design: .serif))
                        .foregroundStyle(AppTheme.Colors.primaryText)
                    
                    Text(reading)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                
                Text(meaning)
                    .font(AppTheme.Typography.example)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                
                if !jlptLevel.isEmpty {
                    Text(jlptLevel.uppercased())
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.vermillion)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.seal)
                                .stroke(AppTheme.Colors.vermillion,
                                        lineWidth: 1)
                        )
                }
            }
            
            Spacer()
            
            Button {
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.Colors.sageGreen)
            }
        }
        .padding(AppTheme.Spacing.md)
        .oboeruCard()
    }
}

#Preview {
    SearchResultCard(
        word: "猫",
        reading: "ねこ",
        meaning: "Cat",
        jlptLevel: "N5"
    )
    .padding()
    .background(AppTheme.Colors.background)
}
