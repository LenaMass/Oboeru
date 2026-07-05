import SwiftUI

struct HomeView: View {
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

    var streakSection: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Current Streak")
                    .font(AppTheme.Typography.sectionHeader)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .textCase(.uppercase)
                    .tracking(1.2)

                HStack(alignment: .firstTextBaseline,
                       spacing: AppTheme.Spacing.xs) {
                    Text("0")
                        .font(AppTheme.Typography.streakNumber)
                        .foregroundStyle(AppTheme.Colors.vermillion)

                    Text("days")
                        .font(AppTheme.Typography.meaning)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }

            Spacer()

            Text("続")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.Colors.vermillion)
        }
        .padding(AppTheme.Spacing.lg)
        .oboeruCard()
    }

    var todaySection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Today")
                    .font(AppTheme.Typography.sectionHeader)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
            }

            HStack(spacing: AppTheme.Spacing.md) {
                todayStatCard(
                    value: "0",
                    label: "Due",
                    color: AppTheme.Colors.vermillion
                )
                todayStatCard(
                    value: "0",
                    label: "New",
                    color: AppTheme.Colors.sageGreen
                )
                todayStatCard(
                    value: "0",
                    label: "Done",
                    color: AppTheme.Colors.gold
                )
            }
        }
    }

    func todayStatCard(value: String,
                       label: String,
                       color: Color) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(value)
                .font(AppTheme.Typography.streakNumber)
                .foregroundStyle(color)

            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .textCase(.uppercase)
                .tracking(1.0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.lg)
        .oboeruCard()
    }

    var actionButtons: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button {
            } label: {
                HStack {
                    Image(systemName: "rectangle.on.rectangle")
                        .font(.system(size: 18, weight: .medium))
                    Text("Start Studying")
                        .font(AppTheme.Typography.meaning)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.Colors.vermillion)
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    headerSection
                    streakSection
                    todaySection
                    Spacer()
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
                    .opacity(0.8)
                    .ignoresSafeArea()
//                    .padding(.leading)
            )
            .background(AppTheme.Colors.background.ignoresSafeArea())
        }
    }
}

#Preview {
    HomeView()
}
