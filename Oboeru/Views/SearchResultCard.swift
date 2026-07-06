import SwiftUI
import CoreData

struct SearchResultCard: View {
    let word: String
    let reading: String
    let meaning: String
    let jlptLevel: String
    
    @State private var isSaved = false
    @Environment(\.managedObjectContext) private var context
    
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
                saveCard()
            } label: {
                Image(systemName: isSaved ?
                      "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(isSaved ?
                                     AppTheme.Colors.sageGreen :
                                     AppTheme.Colors.sageGreen)
                    .animation(AppTheme.Animation.spring, value: isSaved)
            }
            .disabled(isSaved)
            .buttonStyle(.plain)
        }
        .padding(AppTheme.Spacing.md)
        .oboeruCard()
        .onAppear {
            checkIfSaved()
        }
    }
    
    func saveCard() {
        let request = FlashCardEntity.fetchRequest()
        request.predicate = NSPredicate(format: "word == %@", word)
        
        let existing = (try? context.fetch(request)) ?? []
        guard existing.isEmpty else {
            isSaved = true
            return
        }
        
        let entity = FlashCardEntity(context: context)
        entity.id = UUID()
        entity.word = word
        entity.reading = reading
        entity.meaning = meaning
        entity.jlptLevel = jlptLevel
        entity.exampleSentence = ""
        entity.partOfSpeech = ""
        entity.easeFactor = 2.5
        entity.interval = 1
        entity.repetitions = 0
        entity.nextReviewDate = Date()
        entity.lastReviewDate = nil
        entity.isKnown = false
        entity.createdAt = Date()
        
        do {
            try context.save()
            withAnimation(AppTheme.Animation.spring) {
                isSaved = true
            }
        } catch {
            print("Failed to save card: \(error)")
        }
    }
    
    func checkIfSaved() {
        let request = FlashCardEntity.fetchRequest()
        request.predicate = NSPredicate(format: "word == %@", word)
        let results = (try? context.fetch(request)) ?? []
        isSaved = !results.isEmpty
    }
}

#Preview {
    SearchResultCard(
        word: "猫",
        reading: "ねこ",
        meaning: "Cat",
        jlptLevel: "N5"
    )
    .environment(
        \.managedObjectContext,
         PersistenceController.shared.context
    )
    .padding()
    .background(AppTheme.Colors.background)
}
