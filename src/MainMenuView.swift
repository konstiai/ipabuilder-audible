import SwiftUI
import UIKit

// MARK: - 1. Main Menu View

struct MainMenuView: View {
    @EnvironmentObject var store: GameStore
    @EnvironmentObject var sound: SoundManager
    @State private var pulseHero: Bool = false

    var body: some View {
        ZStack {
            // Stadium Night Background
            stadiumBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Top Status Bar (Stars, Coins, Career Rank)
                    topCareerHeader
                        .padding(.top, 8)

                    // Hero Stadium Card
                    heroBannerCard

                    // Primary Quick-Play CTA
                    Button {
                        sound.play(.whistle, volumeScale: 0.7)
                        let nextLvl = min(LevelDatabase.levels.count, max(1, store.highestUnlockedLevel))
                        store.currentScreen = .matchPlay(levelId: nextLvl)
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.22))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "play.fill")
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundColor(.black)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("KARRIERE FORTSETZEN")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundColor(.black)
                                let currentLvl = LevelDatabase.level(for: store.highestUnlockedLevel)
                                Text("Level \(currentLvl.id): \(currentLvl.title) • \(currentLvl.scenarioType.rawValue)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black.opacity(0.75))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.25, green: 0.96, blue: 0.52), Color(red: 0.98, green: 0.82, blue: 0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.green.opacity(0.45), radius: 14, y: 5)
                    }

                    // 2x2 Navigation Grid
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        menuNavCard(
                            title: "LEVELAUSWAHL",
                            subtitle: "\(store.completedLevelsCount)/\(LevelDatabase.levels.count) abgeschlossen",
                            icon: "square.grid.2x2.fill",
                            accent: .cyan
                        ) {
                            sound.play(.menuClick)
                            store.currentScreen = .levelSelect
                        }

                        menuNavCard(
                            title: "KABINE & SHOP",
                            subtitle: "Trikots, Bälle & Erfolge",
                            icon: "tshirt.fill",
                            accent: .yellow
                        ) {
                            sound.play(.menuClick)
                            store.currentScreen = .careerHub
                        }

                        menuNavCard(
                            title: "STEUERUNG & TIPPS",
                            subtitle: "Effet, Pässe & Winkel",
                            icon: "hand.draw.fill",
                            accent: .green
                        ) {
                            sound.play(.menuClick)
                            store.currentScreen = .tutorial
                        }

                        menuNavCard(
                            title: "EINSTELLUNGEN",
                            subtitle: "KI: \(store.difficulty.rawValue) • Sound",
                            icon: "slider.horizontal.3",
                            accent: .purple
                        ) {
                            sound.play(.menuClick)
                            store.currentScreen = .settings
                        }
                    }

                    // Active Kit & Ball Preview Strip
                    activeEquipmentStrip

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulseHero = true
            }
        }
    }

    private var stadiumBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.08, blue: 0.16),
                    Color(red: 0.06, green: 0.18, blue: 0.14),
                    Color(red: 0.04, green: 0.09, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative pitch lines in background
            GeometryReader { geo in
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height
                    path.addEllipse(in: CGRect(x: w * 0.15, y: h * 0.22, width: w * 0.7, height: w * 0.7))
                    path.move(to: CGPoint(x: 0, y: h * 0.42))
                    path.addLine(to: CGPoint(x: w, y: h * 0.42))
                }
                .stroke(Color.white.opacity(0.05), lineWidth: 2)
            }
            .ignoresSafeArea()
        }
    }

    private var topCareerHeader: some View {
        HStack {
            // Career Rank Pill
            HStack(spacing: 8) {
                Image(systemName: "medal.fill")
                    .foregroundColor(.yellow)
                VStack(alignment: .leading, spacing: 1) {
                    Text("KARRIERE-RANG")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    Text(store.stats.careerTitle)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())

            Spacer()

            // Stars Counter
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(store.totalStars)/\(store.maxPossibleStars)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())

            // Coins Counter
            HStack(spacing: 5) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .foregroundColor(.yellow)
                Text("\(store.coins)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
        }
    }

    private var heroBannerCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.45), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 72
                        )
                    )
                    .frame(width: 130, height: 130)
                    .scaleEffect(pulseHero ? 1.08 : 0.94)

                Image(systemName: "soccerball")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .green.opacity(0.7), radius: 12)
            }

            VStack(spacing: 4) {
                Text("SOCCER SUPER STAR")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("PRÄZISE WISCH-STEUERUNG • ECHTE BALLPHYSIK • \(LevelDatabase.levels.count) KARRIERE-LEVEL")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
            }

            // Mini stats row inside hero card
            HStack(spacing: 18) {
                heroStatBadge(label: "Tore", value: "\(store.stats.totalGoals)")
                Divider().frame(height: 22).background(Color.white.opacity(0.2))
                heroStatBadge(label: "Effet-Tore", value: "\(store.stats.curvedGoals)")
                Divider().frame(height: 22).background(Color.white.opacity(0.2))
                heroStatBadge(label: "Stern-Treffer", value: "\(store.stats.starTargetsHit)")
                Divider().frame(height: 22).background(Color.white.opacity(0.2))
                heroStatBadge(label: "Serie", value: "\(store.stats.currentStreak)🔥")
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.16, blue: 0.28).opacity(0.92), Color(red: 0.05, green: 0.24, blue: 0.18).opacity(0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.18), lineWidth: 1.2))
    }

    private func heroStatBadge(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.65))
        }
    }

    private func menuNavCard(title: String, subtitle: String, icon: String, accent: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(accent)
                        .frame(width: 40, height: 40)
                        .background(accent.opacity(0.16))
                        .cornerRadius(12)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.68))
                        .lineLimit(1)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.07))
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
    }

    private var activeEquipmentStrip: some View {
        HStack(spacing: 12) {
            // Active Jersey
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: store.activeKit.primaryHex))
                        .frame(width: 34, height: 34)
                    Circle()
                        .stroke(Color(hex: store.activeKit.secondaryHex), lineWidth: 3)
                        .frame(width: 22, height: 22)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("AKTIVES TRIKOT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.55))
                    Text(store.activeKit.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider().frame(height: 28).background(Color.white.opacity(0.2))

            // Active Ball
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 34, height: 34)
                    Image(systemName: "soccerball")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: store.activeBall.panelColorHex))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("AKTIVER SPIELBALL")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.55))
                    Text(store.activeBall.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
        .onTapGesture {
            sound.play(.menuClick)
            store.currentScreen = .careerHub
        }
    }
}

// MARK: - 2. Level Select View (5 Chapters, 30 Levels)

struct LevelSelectView: View {
    @EnvironmentObject var store: GameStore
    @EnvironmentObject var sound: SoundManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.08, blue: 0.16), Color(red: 0.05, green: 0.16, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                // Top Bar
                HStack {
                    Button {
                        sound.play(.menuClick)
                        store.currentScreen = .mainMenu
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Menü")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    Text("KARRIERE & LEVEL")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(store.totalStars)")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Horizontal Chapter Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(LevelDatabase.chapters) { chapter in
                            let unlocked = store.isChapterUnlocked(chapter)
                            let isSelected = (store.selectedChapterId == chapter.id)
                            Button {
                                sound.play(.menuClick)
                                store.selectedChapterId = chapter.id
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: unlocked ? chapter.badgeIcon : "lock.fill")
                                        .foregroundColor(isSelected ? .black : Color(hex: chapter.themeColorHex))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Kapitel \(chapter.id)")
                                            .font(.system(size: 11, weight: .black, design: .rounded))
                                            .foregroundColor(isSelected ? .black : .white)
                                        Text(chapter.leagueName)
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(isSelected ? .black.opacity(0.75) : .white.opacity(0.65))
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(
                                    isSelected
                                        ? Color(hex: chapter.themeColorHex)
                                        : Color.white.opacity(0.08)
                                )
                                .cornerRadius(14)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Selected Chapter Header Banner
                if let currentChapter = LevelDatabase.chapters.first(where: { $0.id == store.selectedChapterId }) {
                    chapterBanner(currentChapter)
                        .padding(.horizontal, 16)
                }

                // Levels List for Selected Chapter
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 11) {
                        let chapterLevels = LevelDatabase.levels(inChapter: store.selectedChapterId)
                        let regularLevels = chapterLevels.filter { !$0.isSecret }
                        let secretLevels = chapterLevels.filter { $0.isSecret }

                        ForEach(regularLevels) { level in
                            levelRowCard(level)
                        }

                        // Secret Level Card at the bottom of the chapter
                        ForEach(secretLevels) { secretLevel in
                            secretLevelRowCard(secretLevel)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func chapterBanner(_ chapter: CareerChapter) -> some View {
        let unlocked = store.isChapterUnlocked(chapter)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(chapter.title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                if !unlocked {
                    Label("\(chapter.requiredStarsToUnlock) ★ benötigt", systemImage: "lock.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.yellow)
                }
            }
            Text(chapter.description)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.78))
        }
        .padding(14)
        .background(Color(hex: chapter.themeColorHex, opacity: 0.18))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: chapter.themeColorHex, opacity: 0.45), lineWidth: 1))
    }

    private func levelRowCard(_ level: LevelDefinition) -> some View {
        let unlocked = store.isLevelUnlocked(level.id)
        let earnedStars = store.stars(for: level.id)

        return Button {
            guard unlocked else {
                sound.play(.crowdReaction)
                return
            }
            sound.play(.whistle, volumeScale: 0.65)
            store.currentScreen = .matchPlay(levelId: level.id)
        } label: {
            HStack(spacing: 14) {
                // Level Number Badge
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(unlocked ? level.scenarioType.badgeColor.opacity(0.22) : Color.white.opacity(0.06))
                        .frame(width: 52, height: 52)
                    if unlocked {
                        VStack(spacing: 1) {
                            Text("LVL")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(level.scenarioType.badgeColor)
                            Text("\(level.id)")
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white.opacity(0.35))
                    }
                }

                // Level Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(level.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(unlocked ? .white : .white.opacity(0.45))
                            .lineLimit(1)

                        Text(level.scenarioType.rawValue)
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(level.scenarioType.badgeColor)
                            .cornerRadius(4)
                    }

                    Text("\(level.homeTeamName) vs \(level.awayTeamName) • \(level.matchMinute) (\(level.scoreContext))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                        .lineLimit(1)
                }

                Spacer()

                // Stars & Play Arrow
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 3) {
                        ForEach(1...3, id: \.self) { s in
                            Image(systemName: s <= earnedStars ? "star.fill" : "star")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(s <= earnedStars ? .yellow : .white.opacity(0.22))
                        }
                    }

                    if unlocked {
                        Text("ANSTOSS ▶")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(14)
            .background(Color.white.opacity(unlocked ? 0.08 : 0.03))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(unlocked ? Color.white.opacity(0.14) : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }

    private func secretLevelRowCard(_ level: LevelDefinition) -> some View {
        let unlocked = store.isLevelUnlocked(level.id)
        let earnedStars = store.stars(for: level.id)
        let progress = store.chapterRegularProgress(for: level.chapterId)

        return Button {
            guard unlocked else {
                sound.play(.crowdReaction)
                return
            }
            sound.play(.whistle, volumeScale: 0.65)
            store.currentScreen = .matchPlay(levelId: level.id)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 14) {
                    // Secret Badge
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                unlocked
                                    ? LinearGradient(colors: [Color.purple, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.purple.opacity(0.25), Color.black.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 54, height: 54)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(unlocked ? Color.yellow.opacity(0.8) : Color.purple.opacity(0.4), lineWidth: 1.5)
                            )

                        if unlocked {
                            VStack(spacing: 2) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundColor(.yellow)
                                Text("SECRET")
                                    .font(.system(size: 8.5, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.purple.opacity(0.85))
                        }
                    }

                    // Title & Description
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(level.title)
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(unlocked ? .yellow : .white.opacity(0.75))
                                .lineLimit(1)

                            Text("SECRET")
                                .font(.system(size: 8.5, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(unlocked ? Color.yellow : Color.purple.opacity(0.8))
                                .cornerRadius(4)
                        }

                        if unlocked {
                            Text(level.subtitle)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(2)
                        } else {
                            Text("🔒 Freischaltbar: Sammle in allen Spielen dieses Kapitels 3 Sterne! (\(progress.earned)/\(progress.total) ★)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.purple.opacity(0.95))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Spacer()

                    // Stars / Play
                    VStack(alignment: .trailing, spacing: 6) {
                        if unlocked {
                            HStack(spacing: 3) {
                                ForEach(1...3, id: \.self) { s in
                                    Image(systemName: s <= earnedStars ? "star.fill" : "star")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(s <= earnedStars ? .yellow : .white.opacity(0.22))
                                }
                            }
                            Text("SPIELEN ▶")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundColor(.yellow)
                        } else {
                            Text("\(progress.earned)/\(progress.total) ★")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(.purple)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(14)
            .background(
                unlocked
                    ? LinearGradient(colors: [Color.purple.opacity(0.28), Color.pink.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color.purple.opacity(0.10), Color.black.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        unlocked
                            ? Color.yellow.opacity(0.6)
                            : Color.purple.opacity(0.4),
                        lineWidth: unlocked ? 1.5 : 1
                    )
            )
        }
    }
}

// MARK: - 3. Career Hub & Locker Room View

struct CareerHubView: View {
    @EnvironmentObject var store: GameStore
    @EnvironmentObject var sound: SoundManager
    @State private var selectedTab: Int = 0
    @State private var purchaseFeedback: String? = nil

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.08, blue: 0.16), Color(red: 0.07, green: 0.12, blue: 0.22)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                // Header
                HStack {
                    Button {
                        sound.play(.menuClick)
                        store.currentScreen = .mainMenu
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Menü")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    Text("KABINE & KARRIERE")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(store.coins)")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Segmented Picker
                Picker("Bereich", selection: $selectedTab) {
                    Text("Trikots & Bälle").tag(0)
                    Text("Statistik & Pokale").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                if let msg = purchaseFeedback {
                    Text(msg)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 16)
                }

                ScrollView(showsIndicators: false) {
                    if selectedTab == 0 {
                        lockerRoomContent
                    } else {
                        statsAndAchievementsContent
                    }
                }
            }
        }
    }

    private var lockerRoomContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Club Kits Section
            Text("VEREINSTRIKOTS")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.cyan)
                .padding(.horizontal, 16)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(LevelDatabase.kits) { kit in
                    let isUnlocked = store.unlockedKitIds.contains(kit.id)
                    let isSelected = (store.selectedKitId == kit.id)

                    Button {
                        if !store.buyOrSelectKit(kit) {
                            purchaseFeedback = "Noch \(kit.priceCoins - store.coins) Münzen für \(kit.name) benötigt!"
                        } else {
                            purchaseFeedback = "\(kit.name) ausgerüstet!"
                        }
                    } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: kit.primaryHex))
                                    .frame(width: 52, height: 52)
                                Circle()
                                    .stroke(Color(hex: kit.secondaryHex), lineWidth: 5)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "tshirt.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            VStack(spacing: 2) {
                                Text(kit.name)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text(kit.clubTitle)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineLimit(1)
                            }

                            if isSelected {
                                Text("AKTIV")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .clipShape(Capsule())
                            } else if isUnlocked {
                                Text("AUSWÄHLEN")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.16))
                                    .clipShape(Capsule())
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "bitcoinsign.circle.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(kit.priceCoins)")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(.yellow)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.yellow.opacity(0.15))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(isSelected ? 0.14 : 0.06))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isSelected ? Color.green : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)

            // Match Balls Section
            Text("SPIELBÄLLE & FLUGSPUR-EFFEKTE")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.yellow)
                .padding(.horizontal, 16)
                .padding(.top, 6)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(LevelDatabase.balls) { ball in
                    let isUnlocked = store.unlockedBallIds.contains(ball.id)
                    let isSelected = (store.selectedBallId == ball.id)

                    Button {
                        if !store.buyOrSelectBall(ball) {
                            purchaseFeedback = "Noch \(ball.priceCoins - store.coins) Münzen für \(ball.name) benötigt!"
                        } else {
                            purchaseFeedback = "\(ball.name) ausgerüstet!"
                        }
                    } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: ball.trailColorHex, opacity: 0.25))
                                    .frame(width: 56, height: 56)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 42, height: 42)
                                Image(systemName: "soccerball")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: ball.panelColorHex))
                            }

                            VStack(spacing: 2) {
                                Text(ball.name)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text(ball.subtitle)
                                    .font(.system(size: 9.5, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineLimit(1)
                            }

                            if isSelected {
                                Text("AKTIV")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .clipShape(Capsule())
                            } else if isUnlocked {
                                Text("AUSWÄHLEN")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.16))
                                    .clipShape(Capsule())
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "bitcoinsign.circle.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(ball.priceCoins)")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(.yellow)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.yellow.opacity(0.15))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(isSelected ? 0.14 : 0.06))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isSelected ? Color.green : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    private var statsAndAchievementsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Career Statistics Grid
            Text("SPIELER-STATISTIKEN")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.cyan)
                .padding(.horizontal, 16)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                statBox(title: "Erzielte Tore", value: "\(store.stats.totalGoals)", icon: "soccerball", color: .green)
                statBox(title: "Torvorlagen (Assists)", value: "\(store.stats.totalAssists)", icon: "arrow.triangle.branch", color: .cyan)
                statBox(title: "Angeschnittene Tore", value: "\(store.stats.curvedGoals)", icon: "wind", color: .orange)
                statBox(title: "Stern-Winkel-Treffer", value: "\(store.stats.starTargetsHit)", icon: "scope", color: .yellow)
                statBox(title: "Direkt im 1. Versuch", value: "\(store.stats.firstTryWins)", icon: "bolt.fill", color: .purple)
                statBox(title: "Beste Siegesserie", value: "\(store.stats.bestStreak)", icon: "flame.fill", color: .red)
            }
            .padding(.horizontal, 16)

            Text("TROPHÄEN & MEILENSTEINE")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.yellow)
                .padding(.horizontal, 16)
                .padding(.top, 6)

            VStack(spacing: 10) {
                ForEach(store.achievements) { ach in
                    HStack(spacing: 12) {
                        Image(systemName: ach.icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(ach.isUnlocked ? .yellow : .white.opacity(0.3))
                            .frame(width: 44, height: 44)
                            .background(ach.isUnlocked ? Color.yellow.opacity(0.18) : Color.white.opacity(0.06))
                            .cornerRadius(12)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(ach.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(ach.isUnlocked ? .white : .white.opacity(0.5))
                            Text(ach.description)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.65))
                        }

                        Spacer()

                        Text(ach.isUnlocked ? "FREIGESCHALTET" : ach.progressText)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(ach.isUnlocked ? .green : .white.opacity(0.5))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(6)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.16))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.07))
        .cornerRadius(14)
    }
}

// MARK: - 4. Interactive Tutorial View

struct TutorialView: View {
    @EnvironmentObject var store: GameStore
    @EnvironmentObject var sound: SoundManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.08, blue: 0.16), Color(red: 0.05, green: 0.18, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                HStack {
                    Button {
                        sound.play(.menuClick)
                        store.currentScreen = .mainMenu
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Menü")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    Spacer()
                    Text("SPIELANLEITUNG")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 68, height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        tutorialStepCard(
                            number: "1",
                            title: "Direktes Wischen (Swipe-Steuerung)",
                            subtitle: "Wische mit dem Finger direkt in die Richtung, in die du passen oder schießen willst! Kurze Wischbewegungen spielen präzise Pässe, schnelle oder lange Swipes feuern wuchtige Torschüsse ab.",
                            icon: "hand.draw.fill",
                            color: .cyan
                        )

                        tutorialStepCard(
                            number: "2",
                            title: "Effet & Bananen-Kurvenschüsse",
                            subtitle: "Wische deinen Finger in einer Kurve über den Bildschirm (z. B. erst rechts an der Mauer vorbei und dann nach links ins Eck). Der Ball folgt deinem Bogen mit echtem Magnus-Effet!",
                            icon: "wind",
                            color: .orange
                        )

                        tutorialStepCard(
                            number: "3",
                            title: "Steilpässe & Mitspieler-Laufwege",
                            subtitle: "Mitspieler zeigen dir mit gestrichelten Pfeilen ihre geplanten Laufwege in den freien Raum. Spiele ihnen den Ball in den Lauf – sobald sie ihn annehmen, steuerst du den nächsten Zug!",
                            icon: "arrow.triangle.turn.up.right.diamond.fill",
                            color: .green
                        )

                        tutorialStepCard(
                            number: "4",
                            title: "Der goldene Stern-Zielring (★★★)",
                            subtitle: "In jedem Level leuchtet im Tor ein goldener Stern-Ring. Triffst du durch diesen Ring ins Tor, erhältst du sofort die volle 3-Sterne-Wertung und Bonus-Münzen!",
                            icon: "star.circle.fill",
                            color: .yellow
                        )

                        Button {
                            sound.play(.whistle, volumeScale: 0.65)
                            store.currentScreen = .matchPlay(levelId: 1)
                        } label: {
                            Text("JETZT IN LEVEL 1 AUSPROBIEREN ▶")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.green)
                                .cornerRadius(16)
                        }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func tutorialStepCard(number: String, title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("\(number). \(title)")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.35), lineWidth: 1))
    }
}

// MARK: - 5. Settings View

struct SettingsView: View {
    @EnvironmentObject var store: GameStore
    @EnvironmentObject var sound: SoundManager
    @State private var showResetConfirm: Bool = false
    @State private var backupStatusMessage: String? = nil
    @State private var backupStatusIsSuccess: Bool = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.08, blue: 0.16), Color(red: 0.07, green: 0.11, blue: 0.20)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                HStack {
                    Button {
                        sound.play(.menuClick)
                        store.currentScreen = .mainMenu
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Menü")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    Spacer()
                    Text("EINSTELLUNGEN")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 68, height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Difficulty Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("KI-SCHWIERIGKEITSGRAD")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.cyan)

                            Picker("Schwierigkeit", selection: $store.difficulty) {
                                ForEach(DifficultyLevel.allCases) { diff in
                                    Text(diff.rawValue).tag(diff)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text(store.difficulty.description)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(18)

                        // Audio & Haptics Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SOUND & HAPTIK")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.yellow)

                            Toggle("Soundeffekte (Schuss, Pfosten, Pfiff)", isOn: $sound.sfxEnabled)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .tint(.green)

                            Toggle("Stadion-Publikum & Torjubel", isOn: $sound.crowdEnabled)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .tint(.green)

                            Toggle("Vibration & Taptic Engine", isOn: $sound.hapticsEnabled)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .tint(.green)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Gesamtlautstärke")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(sound.sfxVolume * 100))%")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.cyan)
                                }
                                Slider(value: $sound.sfxVolume, in: 0.1...1.0)
                                    .tint(.cyan)
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(18)

                        // Gameplay Helpers & Replay
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GAMEPLAY & KAMERA")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.green)

                            Toggle("3D-Flugbahn-Vorschau beim Ziehen", isOn: $store.showTrajectoryHelper)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .tint(.green)

                            Toggle("Automatische TV-Torwiederholung", isOn: $store.autoReplayGoals)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .tint(.green)

                            Toggle("Alle Level freischalten (Sandbox-Modus)", isOn: $store.sandboxUnlockAll)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .tint(.orange)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(18)

                        // 7-Day Reinstall & Keychain Backup Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(.mint)
                                Text("7-TAGE-NEUINSTALLATION & TRESOR-SPEICHER")
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .foregroundColor(.mint)
                            }

                            Text("Dein kompletter Spielstand (Level, Sterne, Münzen, gekaufte Trikots & Bälle) wird automatisch dreifach gespeichert:\n• iOS Schlüsselbund (bleibt selbst beim Löschen & Neuinstallieren nach 7 Tagen erhalten!)\n• Dateien-App Dokument (SoccerSuperStar_Savegame.json)\n• App-Speicher")
                                .font(.system(size: 11.5, weight: .medium))
                                .foregroundColor(.white.opacity(0.82))
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 10) {
                                Button {
                                    let code = store.exportBackupCode()
                                    if !code.isEmpty {
                                        UIPasteboard.general.string = code
                                        sound.play(.starEarned)
                                        backupStatusIsSuccess = true
                                        backupStatusMessage = "Backup-Code kopiert! (z. B. in Notizen einfügen)"
                                    }
                                } label: {
                                    Label("Code kopieren", systemImage: "doc.on.doc.fill")
                                        .font(.system(size: 12.5, weight: .bold))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 11)
                                        .background(Color.mint)
                                        .cornerRadius(11)
                                }

                                Button {
                                    if let pasted = UIPasteboard.general.string, store.importBackupCode(pasted) {
                                        sound.play(.levelComplete)
                                        backupStatusIsSuccess = true
                                        backupStatusMessage = "Spielstand erfolgreich wiederhergestellt!"
                                    } else {
                                        sound.play(.levelFail)
                                        backupStatusIsSuccess = false
                                        backupStatusMessage = "Kein gültiger SSS1-Backup-Code in der Zwischenablage."
                                    }
                                } label: {
                                    Label("Code laden", systemImage: "arrow.down.doc.fill")
                                        .font(.system(size: 12.5, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 11)
                                        .background(Color.white.opacity(0.16))
                                        .cornerRadius(11)
                                }
                            }

                            if let msg = backupStatusMessage {
                                Text(msg)
                                    .font(.system(size: 11.5, weight: .bold))
                                    .foregroundColor(backupStatusIsSuccess ? .green : .orange)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.mint.opacity(0.35), lineWidth: 1))

                        // Reset Progress
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SPIELSTAND VERWALTEN")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.red)

                            if !showResetConfirm {
                                Button {
                                    sound.play(.menuClick)
                                    showResetConfirm = true
                                } label: {
                                    Label("Karriere-Fortschritt zurücksetzen", systemImage: "trash.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.red.opacity(0.14))
                                        .cornerRadius(12)
                                }
                            } else {
                                HStack(spacing: 10) {
                                    Button {
                                        showResetConfirm = false
                                    } label: {
                                        Text("Abbrechen")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 11)
                                            .background(Color.white.opacity(0.15))
                                            .cornerRadius(10)
                                    }

                                    Button {
                                        sound.play(.whistle)
                                        store.resetAllProgress()
                                        showResetConfirm = false
                                    } label: {
                                        Text("Jetzt löschen")
                                            .font(.system(size: 13, weight: .black))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 11)
                                            .background(Color.red)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(18)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}
