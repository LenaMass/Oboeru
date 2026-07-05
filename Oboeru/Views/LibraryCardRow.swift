import SwiftUI

struct LibraryCardRow: View {
    let word : String
    let reading : String
    let meaning : String
    let daysUntilReview : Int
    let isKnown : Bool
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs){
                HStack(alignment: .firstTextBaseline,spacing:AppTheme.Spacing.xs){
                    Text(word)
                        .font(.system(size:28,weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.Colors.primaryText)
                    
                    Text(reading)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                Text(meaning)
                    .font(AppTheme.Typography.example)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs){
                if isKnown {   Image(systemName: "checmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.sageGreen)
                        .font(.system(size:20))
                }else {
                    Text("in \(daysUntilReview)d")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.vermillion)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.seal)
                                .stroke(AppTheme.Colors.vermillion, lineWidth: 1)
                        )
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .oboeruCard()
    }
}
#Preview {
    LibraryCardRow(
        word: "猫",
        reading: "ねこ",
        meaning: "Cat",
        daysUntilReview: 2,
        isKnown: false
    )
    .padding()
    .background(AppTheme.Colors.background)
}
