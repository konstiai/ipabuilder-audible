import Foundation
import SwiftUI
import Security
import UIKit

// MARK: - Unified Codable Save Profile (Survives 7-Day Sideload Reinstalls)

struct PersistentSaveProfile: Codable {
    var starsByLevel: [Int: Int]
    var highestUnlockedLevel: Int
    var coins: Int
    var difficultyRaw: String
    var selectedKitId: String
    var selectedBallId: String
    var unlockedKitIds: [String]
    var unlockedBallIds: [String]
    var stats: CareerStats
    var sandboxUnlockAll: Bool
    var showTrajectoryHelper: Bool
    var autoReplayGoals: Bool
    var lastSavedTimestamp: Double

    var progressScore: Int {
        let starsSum = starsByLevel.values.reduce(0, +)
        return starsSum * 1000 + highestUnlockedLevel * 100 + unlockedKitIds.count * 50 + unlockedBallIds.count * 50 + stats.totalGoals * 10 + coins
    }
}

final class GameStore: ObservableObject {
    // MARK: - Navigation
    @Published var currentScreen: AppScreen = .mainMenu
    @Published var selectedChapterId: Int = 1

    // MARK: - Persistent Progression State
    @Published var starsByLevel: [Int: Int] = [:] {
        didSet { saveEverywhere() }
    }
    @Published var highestUnlockedLevel: Int = 1 {
        didSet { saveEverywhere() }
    }
    @Published var coins: Int = 100 {
        didSet { saveEverywhere() }
    }
    @Published var difficulty: DifficultyLevel = .pro {
        didSet { saveEverywhere() }
    }
    @Published var selectedKitId: String = "kit_royal" {
        didSet { saveEverywhere() }
    }
    @Published var selectedBallId: String = "ball_classic" {
        didSet { saveEverywhere() }
    }
    @Published var unlockedKitIds: Set<String> = ["kit_royal"] {
        didSet { saveEverywhere() }
    }
    @Published var unlockedBallIds: Set<String> = ["ball_classic"] {
        didSet { saveEverywhere() }
    }
    @Published var stats: CareerStats = CareerStats() {
        didSet { saveEverywhere() }
    }
    @Published var sandboxUnlockAll: Bool = false {
        didSet { saveEverywhere() }
    }
    @Published var showTrajectoryHelper: Bool = false {
        didSet { saveEverywhere() }
    }
    @Published var autoReplayGoals: Bool = true {
        didSet { saveEverywhere() }
    }

    private var isLoadingProfile: Bool = false

    // Storage Keys
    private static let masterDefaultsKey = "soccer_superstar_master_profile_v2"
    private static let keychainService = "com.konsti.soccergame.vault"
    private static let keychainAccount = "master_save_profile_v1"
    private static let documentsFileName = "SoccerSuperStar_Savegame.json"

    // Legacy v1 keys for seamless migration
    private static let legacyStarsKey = "soccer_superstar_stars_v1"
    private static let legacyHighestLevelKey = "soccer_superstar_highest_level_v1"
    private static let legacyCoinsKey = "soccer_superstar_coins_v1"
    private static let legacyUnlockedKitsKey = "soccer_superstar_unlocked_kits_v1"
    private static let legacyUnlockedBallsKey = "soccer_superstar_unlocked_balls_v1"
    private static let legacySelectedKitKey = "soccer_superstar_selected_kit_v1"
    private static let legacySelectedBallKey = "soccer_superstar_selected_ball_v1"
    private static let legacyStatsKey = "soccer_superstar_career_stats_v1"

    init() {
        isLoadingProfile = true
        loadBestAvailableProfile()
        isLoadingProfile = false
        // Immediately synchronize the winning profile across Keychain, Documents, and UserDefaults
        saveEverywhere()
    }

    // MARK: - Multi-Layer Load & Save (Keychain + Documents + UserDefaults)

    private func loadBestAvailableProfile() {
        var candidates: [PersistentSaveProfile] = []

        // 1. Load from iOS Keychain (Survives App Deletion & 7-Day Reinstall!)
        if let kcData = Self.readFromKeychain(),
           let kcProfile = try? JSONDecoder().decode(PersistentSaveProfile.self, from: kcData) {
            candidates.append(kcProfile)
        }

        // 2. Load from Documents JSON file
        if let docURL = Self.documentsFileURL(),
           let docData = try? Data(contentsOf: docURL),
           let docProfile = try? JSONDecoder().decode(PersistentSaveProfile.self, from: docData) {
            candidates.append(docProfile)
        }

        // 3. Load from UserDefaults Master Profile
        if let defData = UserDefaults.standard.data(forKey: Self.masterDefaultsKey),
           let defProfile = try? JSONDecoder().decode(PersistentSaveProfile.self, from: defData) {
            candidates.append(defProfile)
        }

        // 4. Check legacy v1 UserDefaults if upgrading from first version
        if let legacyProfile = Self.loadLegacyV1Profile() {
            candidates.append(legacyProfile)
        }

        // Pick the profile with the highest progress score so no progress is ever lost
        if let best = candidates.max(by: { $0.progressScore < $1.progressScore }) {
            applyProfile(best)
        }
    }

    private func applyProfile(_ profile: PersistentSaveProfile) {
        self.starsByLevel = profile.starsByLevel
        self.highestUnlockedLevel = max(1, profile.highestUnlockedLevel)
        self.coins = max(0, profile.coins)
        self.difficulty = DifficultyLevel(rawValue: profile.difficultyRaw) ?? .pro
        self.selectedKitId = profile.selectedKitId
        self.selectedBallId = profile.selectedBallId
        var kits = Set(profile.unlockedKitIds)
        kits.insert("kit_royal")
        self.unlockedKitIds = kits
        var balls = Set(profile.unlockedBallIds)
        balls.insert("ball_classic")
        self.unlockedBallIds = balls
        self.stats = profile.stats
        self.sandboxUnlockAll = profile.sandboxUnlockAll
        self.showTrajectoryHelper = profile.showTrajectoryHelper
        self.autoReplayGoals = profile.autoReplayGoals
    }

    private func currentProfile() -> PersistentSaveProfile {
        PersistentSaveProfile(
            starsByLevel: starsByLevel,
            highestUnlockedLevel: highestUnlockedLevel,
            coins: coins,
            difficultyRaw: difficulty.rawValue,
            selectedKitId: selectedKitId,
            selectedBallId: selectedBallId,
            unlockedKitIds: Array(unlockedKitIds),
            unlockedBallIds: Array(unlockedBallIds),
            stats: stats,
            sandboxUnlockAll: sandboxUnlockAll,
            showTrajectoryHelper: showTrajectoryHelper,
            autoReplayGoals: autoReplayGoals,
            lastSavedTimestamp: Date().timeIntervalSince1970
        )
    }

    func saveEverywhere() {
        guard !isLoadingProfile else { return }
        let profile = currentProfile()
        guard let data = try? JSONEncoder().encode(profile) else { return }

        // 1. Save to UserDefaults
        UserDefaults.standard.set(data, forKey: Self.masterDefaultsKey)

        // 2. Save to iOS Keychain (Persists even when app is deleted before 7-day reinstall!)
        Self.writeToKeychain(data: data)

        // 3. Save to Documents folder (Visible in iOS Files app)
        if let url = Self.documentsFileURL() {
            try? data.write(to: url, options: [.atomic])
        }
    }

    // MARK: - Manual Backup Code Export / Import (Extra Safety for Bundle-ID Changes)

    func exportBackupCode() -> String {
        let profile = currentProfile()
        guard let data = try? JSONEncoder().encode(profile) else { return "" }
        return "SSS1-" + data.base64EncodedString()
    }

    @discardableResult
    func importBackupCode(_ rawCode: String) -> Bool {
        let trimmed = rawCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let base64Part = trimmed.hasPrefix("SSS1-") ? String(trimmed.dropFirst(5)) : trimmed
        guard let data = Data(base64Encoded: base64Part),
              let decoded = try? JSONDecoder().decode(PersistentSaveProfile.self, from: data) else {
            return false
        }
        isLoadingProfile = true
        applyProfile(decoded)
        isLoadingProfile = false
        saveEverywhere()
        return true
    }

    // MARK: - iOS Keychain Helpers

    private static func writeToKeychain(data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            SecItemAdd(addQuery as CFDictionary, nil)
        }
    }

    private static func readFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    private static func deleteFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(query as CFDictionary)
    }

    private static func documentsFileURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(documentsFileName)
    }

    private static func loadLegacyV1Profile() -> PersistentSaveProfile? {
        let defaults = UserDefaults.standard
        let highest = defaults.integer(forKey: legacyHighestLevelKey)
        let hasStars = defaults.data(forKey: legacyStarsKey) != nil
        guard highest > 1 || hasStars else { return nil }

        let stars = (defaults.data(forKey: legacyStarsKey)).flatMap { try? JSONDecoder().decode([Int: Int].self, from: $0) } ?? [:]
        let coins = defaults.object(forKey: legacyCoinsKey) != nil ? defaults.integer(forKey: legacyCoinsKey) : 100
        let kits = defaults.stringArray(forKey: legacyUnlockedKitsKey) ?? ["kit_royal"]
        let balls = defaults.stringArray(forKey: legacyUnlockedBallsKey) ?? ["ball_classic"]
        let selKit = defaults.string(forKey: legacySelectedKitKey) ?? "kit_royal"
        let selBall = defaults.string(forKey: legacySelectedBallKey) ?? "ball_classic"
        let stats = (defaults.data(forKey: legacyStatsKey)).flatMap { try? JSONDecoder().decode(CareerStats.self, from: $0) } ?? CareerStats()

        return PersistentSaveProfile(
            starsByLevel: stars,
            highestUnlockedLevel: max(1, highest),
            coins: coins,
            difficultyRaw: DifficultyLevel.pro.rawValue,
            selectedKitId: selKit,
            selectedBallId: selBall,
            unlockedKitIds: kits,
            unlockedBallIds: balls,
            stats: stats,
            sandboxUnlockAll: false,
            showTrajectoryHelper: false,
            autoReplayGoals: true,
            lastSavedTimestamp: Date().timeIntervalSince1970
        )
    }

    // MARK: - Computed Properties

    var totalStars: Int {
        starsByLevel.values.reduce(0, +)
    }

    var maxPossibleStars: Int {
        LevelDatabase.levels.count * 3
    }

    var completedLevelsCount: Int {
        starsByLevel.values.filter { $0 > 0 }.count
    }

    var activeKit: JerseyKit {
        LevelDatabase.kits.first(where: { $0.id == selectedKitId }) ?? LevelDatabase.kits[0]
    }

    var activeBall: BallDesign {
        LevelDatabase.balls.first(where: { $0.id == selectedBallId }) ?? LevelDatabase.balls[0]
    }

    func stars(for levelId: Int) -> Int {
        starsByLevel[levelId] ?? 0
    }

    func isLevelUnlocked(_ levelId: Int) -> Bool {
        if sandboxUnlockAll { return true }
        if levelId <= 1 { return true }
        let level = LevelDatabase.level(for: levelId)
        if let chapter = LevelDatabase.chapters.first(where: { $0.id == level.chapterId }) {
            if totalStars < chapter.requiredStarsToUnlock && levelId > highestUnlockedLevel {
                return false
            }
        }
        return levelId <= highestUnlockedLevel
    }

    func isChapterUnlocked(_ chapter: CareerChapter) -> Bool {
        if sandboxUnlockAll { return true }
        if chapter.id == 1 { return true }
        let firstLevelOfChapter = LevelDatabase.levels.first(where: { $0.chapterId == chapter.id })?.id ?? ((chapter.id - 1) * 6 + 1)
        return totalStars >= chapter.requiredStarsToUnlock || highestUnlockedLevel >= firstLevelOfChapter
    }

    // MARK: - Actions

    func recordLevelWin(
        levelId: Int,
        earnedStars: Int,
        attemptsUsed: Int,
        passesCompleted: Int,
        wasCurvedGoal: Bool,
        hitStarTarget: Bool
    ) -> Int {
        let level = LevelDatabase.level(for: levelId)
        let previousStars = starsByLevel[levelId] ?? 0
        if earnedStars > previousStars {
            starsByLevel[levelId] = earnedStars
        }

        if levelId >= highestUnlockedLevel && levelId < LevelDatabase.levels.count {
            highestUnlockedLevel = levelId + 1
        }

        let starDelta = max(0, earnedStars - previousStars)
        let baseReward = starDelta > 0
            ? Int(Double(level.rewardCoins) * (Double(earnedStars) / 3.0))
            : max(15, level.rewardCoins / 4)
        let totalCoinReward = Int(Double(baseReward) * difficulty.coinBonusMultiplier)
        coins += totalCoinReward

        stats.totalGoals += 1
        stats.totalPassesCompleted += passesCompleted
        if passesCompleted > 0 {
            stats.totalAssists += 1
        }
        if wasCurvedGoal {
            stats.curvedGoals += 1
        }
        if hitStarTarget {
            stats.starTargetsHit += 1
        }
        if attemptsUsed == 1 {
            stats.firstTryWins += 1
        }
        stats.currentStreak += 1
        if stats.currentStreak > stats.bestStreak {
            stats.bestStreak = stats.currentStreak
        }

        saveEverywhere()
        return totalCoinReward
    }

    func recordAttemptFailure() {
        stats.totalAttempts += 1
        stats.currentStreak = 0
        saveEverywhere()
    }

    func recordWoodworkHit() {
        stats.woodworkHits += 1
        saveEverywhere()
    }

    func buyOrSelectKit(_ kit: JerseyKit) -> Bool {
        if unlockedKitIds.contains(kit.id) {
            selectedKitId = kit.id
            SoundManager.shared.play(.menuClick)
            return true
        }
        guard coins >= kit.priceCoins else { return false }
        coins -= kit.priceCoins
        unlockedKitIds.insert(kit.id)
        selectedKitId = kit.id
        saveEverywhere()
        SoundManager.shared.play(.starEarned)
        return true
    }

    func buyOrSelectBall(_ ball: BallDesign) -> Bool {
        if unlockedBallIds.contains(ball.id) {
            selectedBallId = ball.id
            SoundManager.shared.play(.menuClick)
            return true
        }
        guard coins >= ball.priceCoins else { return false }
        coins -= ball.priceCoins
        unlockedBallIds.insert(ball.id)
        selectedBallId = ball.id
        saveEverywhere()
        SoundManager.shared.play(.starEarned)
        return true
    }

    func resetAllProgress() {
        isLoadingProfile = true
        starsByLevel = [:]
        highestUnlockedLevel = 1
        coins = 100
        unlockedKitIds = ["kit_royal"]
        unlockedBallIds = ["ball_classic"]
        selectedKitId = "kit_royal"
        selectedBallId = "ball_classic"
        stats = CareerStats()
        sandboxUnlockAll = false
        isLoadingProfile = false

        Self.deleteFromKeychain()
        if let docURL = Self.documentsFileURL() {
            try? FileManager.default.removeItem(at: docURL)
        }
        saveEverywhere()
    }

    // MARK: - Achievements List

    var achievements: [AchievementItem] {
        [
            AchievementItem(
                id: "ach_first_goal",
                title: "Torjäger-Debüt",
                description: "Erziele dein erstes Tor in der Karriere.",
                icon: "soccerball",
                isUnlocked: stats.totalGoals >= 1,
                progressText: "\(min(1, stats.totalGoals))/1"
            ),
            AchievementItem(
                id: "ach_curve_master",
                title: "Bananenflanken-König",
                description: "Erziele 5 Tore mit angeschnittenem Effet-Schuss.",
                icon: "wind",
                isUnlocked: stats.curvedGoals >= 5,
                progressText: "\(min(5, stats.curvedGoals))/5"
            ),
            AchievementItem(
                id: "ach_star_sniper",
                title: "Winkel-Scharfschütze",
                description: "Triff 8-mal den goldenen Stern-Zielring im Torwinkel.",
                icon: "scope",
                isUnlocked: stats.starTargetsHit >= 8,
                progressText: "\(min(8, stats.starTargetsHit))/8"
            ),
            AchievementItem(
                id: "ach_playmaker",
                title: "Tiki-Taka-Regisseur",
                description: "Schließe 15 erfolgreiche Pässe im Spielaufbau ab.",
                icon: "point.3.connected.trianglepath.dotted",
                isUnlocked: stats.totalPassesCompleted >= 15,
                progressText: "\(min(15, stats.totalPassesCompleted))/15"
            ),
            AchievementItem(
                id: "ach_one_shot",
                title: "Eiskalter Vollstrecker",
                description: "Gewinne 10 Level direkt im allerersten Versuch.",
                icon: "bolt.fill",
                isUnlocked: stats.firstTryWins >= 10,
                progressText: "\(min(10, stats.firstTryWins))/10"
            ),
            AchievementItem(
                id: "ach_world_champ",
                title: "Weltpokal-Legende",
                description: "Gewinne Level 30 (Das große WM-Finale).",
                icon: "trophy.fill",
                isUnlocked: (starsByLevel[30] ?? 0) > 0,
                progressText: (starsByLevel[30] ?? 0) > 0 ? "1/1" : "0/1"
            )
        ]
    }
}
