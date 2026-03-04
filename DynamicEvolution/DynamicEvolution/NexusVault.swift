// NexusVault.swift — Core Game Engine, Daily Challenge & Lifetime Stats
import Foundation

// MARK: - NexusVault

/// Central game engine that drives all session state: probability weights,
/// grid management, fusion evaluation, scoring, quest / daily challenge
/// configuration, leaderboard persistence, and lifetime statistics tracking.
class NexusVault {

    // MARK: - Probability Baseline

    private static let defaultWeights: [GlyphTier: Double] = [
        .seedling: 40, .verdant: 20, .sapling: 15, .arbor: 10,
        .ancient:   7, .mystic:   5, .legendary:  2, .divine:   1
    ]

    // MARK: - Session State

    private(set) var orbitalWeights: [GlyphTier: Double] = defaultWeights
    private(set) var apexTierReached: GlyphTier? = nil
    private(set) var totalLuminance: Int = 0
    private(set) var cascadeDepth: Int = 0
    private(set) var peakCascade: Int = 0
    private(set) var spinCount: Int = 0
    private(set) var dormantStreak: Int = 0
    private(set) var totalFusionsPerformed: Int = 0
    private(set) var gridCells: [GlyphTier?] = []

    // MARK: - Mode & Quest State

    private(set) var warpMode: WarpMode = .timedBlitz
    private(set) var questSpinsLeft: Int = 12
    private(set) var questTarget: GlyphTier = .arbor
    private(set) var questTargetCount: Int = 1

    // MARK: - Quest Configuration Table

    static let questConfigs: [(spins: Int, target: GlyphTier, count: Int)] = {
        var table = [(spins: Int, target: GlyphTier, count: Int)]()
        for lv in 1...100 {
            let entry: (Int, GlyphTier, Int)
            switch lv {
            case  1...3:   entry = (15, .arbor, 1)
            case  4...6:   entry = (14, .arbor, 2)
            case  7...9:   entry = (13, .arbor, 3)
            case 10...12:  entry = (12, .arbor, 4)
            case 13...15:  entry = (14, .ancient, 1)
            case 16...18:  entry = (13, .ancient, 1)
            case 19...21:  entry = (12, .ancient, 2)
            case 22...24:  entry = (11, .ancient, 2)
            case 25...28:  entry = (10, .ancient, 3)
            case 29...31:  entry = (14, .mystic, 1)
            case 32...34:  entry = (13, .mystic, 1)
            case 35...37:  entry = (12, .mystic, 2)
            case 38...40:  entry = (11, .mystic, 2)
            case 41...43:  entry = (10, .mystic, 3)
            case 44...46:  entry = (9,  .mystic, 3)
            case 47...48:  entry = (8,  .mystic, 4)
            case 49...51:  entry = (14, .legendary, 1)
            case 52...54:  entry = (13, .legendary, 1)
            case 55...57:  entry = (12, .legendary, 1)
            case 58...60:  entry = (11, .legendary, 2)
            case 61...63:  entry = (10, .legendary, 2)
            case 64...66:  entry = (9,  .legendary, 2)
            case 67...69:  entry = (8,  .legendary, 3)
            case 70...72:  entry = (8,  .legendary, 3)
            case 73...75:  entry = (15, .divine, 1)
            case 76...78:  entry = (14, .divine, 1)
            case 79...81:  entry = (13, .divine, 1)
            case 82...84:  entry = (12, .divine, 1)
            case 85...87:  entry = (11, .divine, 2)
            case 88...90:  entry = (10, .divine, 2)
            case 91...93:  entry = (9,  .divine, 2)
            case 94...96:  entry = (8,  .divine, 3)
            case 97...99:  entry = (7,  .divine, 3)
            case 100:      entry = (6,  .divine, 3)
            default:       entry = (6,  .divine, 3)
            }
            table.append((spins: entry.0, target: entry.1, count: entry.2))
        }
        return table
    }()

    // MARK: - Mode Configuration

    func configureWarpMode(_ mode: WarpMode) {
        warpMode = mode
        resetSession()

        switch mode {
        case .questRun(let lvl):
            let idx          = min(lvl - 1, NexusVault.questConfigs.count - 1)
            let cfg          = NexusVault.questConfigs[idx]
            questSpinsLeft   = cfg.spins
            questTarget      = cfg.target
            questTargetCount = cfg.count

        case .dailyChallenge(let stamp):
            let challenge    = NexusVault.dailyChallengeForToday(overrideStamp: stamp)
            questSpinsLeft   = challenge.spins
            questTarget      = challenge.target
            questTargetCount = challenge.count

        case .timedBlitz:
            break
        }
    }

    func resetSession() {
        orbitalWeights        = NexusVault.defaultWeights
        apexTierReached       = nil
        totalLuminance        = 0
        cascadeDepth          = 0
        peakCascade           = 0
        spinCount             = 0
        dormantStreak         = 0
        totalFusionsPerformed = 0
        gridCells             = []
        questTargetCount      = 1
    }

    // MARK: - Spin Execution

    func executeSpin() -> [GlyphTier?] {
        spinCount += 1

        switch warpMode {
        case .questRun, .dailyChallenge:
            questSpinsLeft -= 1
        case .timedBlitz:
            break
        }

        if gridCells.isEmpty {
            gridCells = (0..<16).map { _ in sampleGlyph() }
        } else {
            for i in gridCells.indices where gridCells[i] == nil {
                gridCells[i] = sampleGlyph()
            }
        }
        return gridCells
    }

    private func sampleGlyph() -> GlyphTier {
        let totalWeight = orbitalWeights.values.reduce(0, +)
        var roll = Double.random(in: 0..<totalWeight)
        for tier in GlyphTier.allCases {
            let w = orbitalWeights[tier] ?? 0
            if roll < w { return tier }
            roll -= w
        }
        return .seedling
    }

    // MARK: - Fusion Data Types

    struct FusionStep {
        let sourceTier: GlyphTier
        let resultTier: GlyphTier
        let baseIndex: Int
        let consumedIndices: [Int]
        let gridSnapshot: [GlyphTier?]
    }

    struct FusionResult {
        let newApex: GlyphTier?
        let comboCount: Int
        let scoreGained: Int
        let updatedGrid: [GlyphTier?]
        let steps: [FusionStep]
    }

    // MARK: - Fusion Resolution

    func runFusionCycle() -> FusionResult {
        var cells   = gridCells
        var combo   = 0
        var earned  = 0
        var freshApex: GlyphTier? = nil
        var steps: [FusionStep] = []

        while let fusableTier = findLowestFusable(in: cells) {
            let matches = cells.indices.filter { cells[$0] == fusableTier }
            let picked  = Array(matches.shuffled().prefix(3))
            let upgraded = fusableTier.next ?? fusableTier

            var nextGrid = cells
            nextGrid[picked[0]] = upgraded
            nextGrid[picked[1]] = nil
            nextGrid[picked[2]] = nil
            cells = nextGrid

            combo += 1
            totalFusionsPerformed += 1

            steps.append(FusionStep(
                sourceTier:      fusableTier,
                resultTier:      upgraded,
                baseIndex:       picked[0],
                consumedIndices: [picked[1], picked[2]],
                gridSnapshot:    cells
            ))

            earned += scoreFusion(tier: upgraded, depth: combo)

            if let prev = apexTierReached {
                if upgraded.rawValue > prev.rawValue { freshApex = upgraded }
            } else {
                freshApex = upgraded
            }
        }

        gridCells      = cells
        cascadeDepth   = combo
        if combo > peakCascade { peakCascade = combo }
        totalLuminance += earned
        dormantStreak  = combo == 0 ? dormantStreak + 1 : 0

        if let apex = freshApex {
            apexTierReached = apex
            adjustWeights(forNewApex: apex)
        }

        return FusionResult(
            newApex:     freshApex,
            comboCount:  combo,
            scoreGained: earned,
            updatedGrid: cells,
            steps:       steps
        )
    }

    private func scoreFusion(tier: GlyphTier, depth: Int) -> Int {
        let base = Double(tier.rawValue * tier.rawValue * 20)
        let mult = 1.0 + Double(depth) * 0.25
        var pts  = Int(base * mult)
        if tier == .legendary { pts += 500 }
        if tier == .divine    { pts += 1500 }
        return pts
    }

    // MARK: - Weight Adjustment

    private func adjustWeights(forNewApex apex: GlyphTier) {
        let rank = apex.rawValue
        var w = orbitalWeights

        w[apex] = min((w[apex] ?? 0) + 3.0, 25.0)

        if let above = GlyphTier(rawValue: rank + 1) {
            w[above] = min((w[above] ?? 0) + 2.0, 25.0)
        } else {
            w[apex] = min((w[apex] ?? 0) + 2.0, 25.0)
        }

        let lowerTiers = GlyphTier.allCases.filter { $0.rawValue < rank }
        var budget = 5.0
        for tier in lowerTiers.reversed() {
            let current  = w[tier] ?? 0
            let floor: Double = tier == .seedling ? 10.0 : 0.5
            let room     = max(0, current - floor)
            let cut      = min(room, budget)
            w[tier]      = current - cut
            budget      -= cut
            if budget <= 0 { break }
        }

        let sum = w.values.reduce(0, +)
        if abs(sum - 100.0) > 0.01 {
            let delta = 100.0 - sum
            w[.seedling] = max((w[.seedling] ?? 0) + delta, 10.0)
        }
        orbitalWeights = w
    }

    // MARK: - Grid Search

    private func findLowestFusable(in cells: [GlyphTier?]) -> GlyphTier? {
        for tier in GlyphTier.allCases {
            if cells.filter({ $0 == tier }).count >= 3 { return tier }
        }
        return nil
    }

    // MARK: - Grid Analysis

    var hasActiveFusion: Bool {
        findLowestFusable(in: gridCells) != nil
    }

    var dominantTier: GlyphTier? {
        let filled = gridCells.compactMap { $0 }
        guard !filled.isEmpty else { return nil }
        var counts = [GlyphTier: Int]()
        filled.forEach { counts[$0, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    var questProgressFraction: Double {
        switch warpMode {
        case .questRun, .dailyChallenge:
            guard questTargetCount > 0 else { return 0 }
            let onGrid = gridCells.compactMap({ $0 })
                .filter { $0.rawValue >= questTarget.rawValue }.count
            return min(Double(onGrid) / Double(questTargetCount), 1.0)
        case .timedBlitz:
            return 0
        }
    }

    var questTargetCountOnGrid: Int {
        gridCells.compactMap({ $0 }).filter { $0.rawValue >= questTarget.rawValue }.count
    }

    var spinBudgetFraction: Double {
        switch warpMode {
        case .questRun(let lvl):
            let idx   = min(lvl - 1, NexusVault.questConfigs.count - 1)
            let total = Double(NexusVault.questConfigs[idx].spins)
            guard total > 0 else { return 0 }
            return max(0, Double(questSpinsLeft) / total)

        case .dailyChallenge(let stamp):
            let daily = NexusVault.dailyChallengeForToday(overrideStamp: stamp)
            let total = Double(daily.spins)
            guard total > 0 else { return 0 }
            return max(0, Double(questSpinsLeft) / total)

        case .timedBlitz:
            return 1
        }
    }

    // MARK: - End Conditions

    var isQuestComplete: Bool {
        switch warpMode {
        case .questRun, .dailyChallenge:
            return questTargetCountOnGrid >= questTargetCount
        case .timedBlitz:
            return false
        }
    }

    var isQuestFailed: Bool {
        switch warpMode {
        case .questRun, .dailyChallenge:
            return questSpinsLeft <= 0 && !isQuestComplete
        case .timedBlitz:
            return false
        }
    }

    var isInfiniteGameOver: Bool { false }

    // MARK: - Display Helpers

    func weightDescription() -> String {
        GlyphTier.allCases.map { t in
            String(format: "Lv%d:%.1f%%", t.rawValue, orbitalWeights[t] ?? 0)
        }.joined(separator: " ")
    }

    func formattedWeightRows() -> (top: String, bottom: String) {
        let tiers = GlyphTier.allCases
        let top = tiers.prefix(4).map { t in
            String(format: "%@:%.0f%%", t.shortLabel, orbitalWeights[t] ?? 0)
        }.joined(separator: "  ")
        let bot = tiers.suffix(4).map { t in
            String(format: "%@:%.0f%%", t.shortLabel, orbitalWeights[t] ?? 0)
        }.joined(separator: "  ")
        return (top, bot)
    }

    // MARK: - Grid Statistics

    func apexTierStats() -> (tier: GlyphTier, count: Int)? {
        let filled = gridCells.compactMap { $0 }
        guard !filled.isEmpty else { return nil }
        let highest = filled.max(by: { $0.rawValue < $1.rawValue })!
        let count   = filled.filter { $0 == highest }.count
        return (highest, count)
    }

    func gridTierCounts() -> [GlyphTier: Int] {
        var counts = [GlyphTier: Int]()
        gridCells.compactMap({ $0 }).forEach { counts[$0, default: 0] += 1 }
        return counts
    }

    var filledCellCount: Int { gridCells.compactMap({ $0 }).count }
    var emptyCellCount: Int  { gridCells.filter({ $0 == nil }).count }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Quest Progress Persistence
    // ═══════════════════════════════════════════════════════════════════

    private static let questProgressKey = "DynamicEvolution_QuestMaxLevel"

    static var savedQuestLevel: Int {
        max(UserDefaults.standard.integer(forKey: questProgressKey), 1)
    }

    static func saveQuestLevel(_ level: Int) {
        let current = UserDefaults.standard.integer(forKey: questProgressKey)
        if level > current {
            UserDefaults.standard.set(level, forKey: questProgressKey)
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Leaderboard (Timed Blitz)
    // ═══════════════════════════════════════════════════════════════════

    struct LeaderboardEntry: Codable {
        let score: Int
        let apexTier: Int
        let apexCount: Int
        let date: Date
    }

    private static let leaderboardKey = "DynamicEvolution_Leaderboard"

    static func loadLeaderboard() -> [LeaderboardEntry] {
        guard let data    = UserDefaults.standard.data(forKey: leaderboardKey),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data)
        else { return [] }
        return entries.sorted { $0.score > $1.score }
    }

    static func saveToLeaderboard(score: Int, apexTier: GlyphTier?, apexCount: Int) {
        var entries = loadLeaderboard()
        entries.append(LeaderboardEntry(
            score:     score,
            apexTier:  apexTier?.rawValue ?? 0,
            apexCount: apexCount,
            date:      Date()
        ))
        entries.sort { $0.score > $1.score }
        if entries.count > 10 { entries = Array(entries.prefix(10)) }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: leaderboardKey)
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Daily Challenge
    // ═══════════════════════════════════════════════════════════════════

    /// Returns today's date as an integer in YYYYMMDD format.
    static func dayStamp() -> Int {
        let cal = Calendar.current
        let now = Date()
        let y = cal.component(.year,  from: now)
        let m = cal.component(.month, from: now)
        let d = cal.component(.day,   from: now)
        return y * 10000 + m * 100 + d
    }

    /// Deterministically generate a daily challenge from any dayStamp.
    static func dailyChallengeForToday(
        overrideStamp: Int? = nil
    ) -> (dayStamp: Int, spins: Int, target: GlyphTier, count: Int, seed: UInt64) {
        let stamp = overrideStamp ?? dayStamp()
        let seed  = UInt64(abs(stamp)) &* 6364136223846793005 &+ 1442695040888963407

        let targetPool: [(GlyphTier, Int, ClosedRange<Int>)] = [
            (.arbor,     3, 12...15),
            (.ancient,   2, 11...14),
            (.ancient,   3, 10...13),
            (.mystic,    1, 12...15),
            (.mystic,    2, 10...13),
            (.legendary, 1, 12...15),
            (.legendary, 2, 10...13),
            (.divine,    1, 13...16),
        ]

        let pick  = Int(seed >> 16) % targetPool.count
        let entry = targetPool[pick]
        let range = entry.2
        let spins = range.lowerBound + Int(seed >> 32) % (range.count)

        return (dayStamp: stamp, spins: spins, target: entry.0, count: entry.1, seed: seed)
    }

    /// Human-readable date string for a dayStamp, e.g. "Mar 04, 2026".
    static func dailyLabel(for stamp: Int) -> String {
        let y = stamp / 10000
        let m = (stamp / 100) % 100
        let d = stamp % 100

        var comps        = DateComponents()
        comps.year       = y
        comps.month      = m
        comps.day        = d
        let cal = Calendar.current
        guard let date = cal.date(from: comps) else { return "Day \(stamp)" }

        let fmt            = DateFormatter()
        fmt.dateFormat     = "MMM dd, yyyy"
        fmt.locale         = Locale(identifier: "en_US")
        return fmt.string(from: date)
    }

    // MARK: Daily Best Score

    private static let dailyBestPrefix = "DynEvo_DailyBest_"

    static func dailyBestScore(for stamp: Int) -> Int {
        UserDefaults.standard.integer(forKey: dailyBestPrefix + "\(stamp)")
    }

    private static func saveDailyBest(score: Int, for stamp: Int) {
        let key     = dailyBestPrefix + "\(stamp)"
        let current = UserDefaults.standard.integer(forKey: key)
        if score > current {
            UserDefaults.standard.set(score, forKey: key)
        }
    }

    // MARK: Daily Win Streak

    private static let dailyStreakKey     = "DynEvo_DailyStreak"
    private static let dailyLastWinKey    = "DynEvo_DailyLastWin"

    static var dailyStreak: Int {
        UserDefaults.standard.integer(forKey: dailyStreakKey)
    }

    private static func updateDailyStreak(won: Bool, stamp: Int) {
        if won {
            let lastWin = UserDefaults.standard.integer(forKey: dailyLastWinKey)
            if lastWin == stamp { return }

            let yesterday = previousDayStamp(from: stamp)
            if lastWin == yesterday || lastWin == 0 {
                let streak = UserDefaults.standard.integer(forKey: dailyStreakKey) + 1
                UserDefaults.standard.set(streak, forKey: dailyStreakKey)
            } else {
                UserDefaults.standard.set(1, forKey: dailyStreakKey)
            }
            UserDefaults.standard.set(stamp, forKey: dailyLastWinKey)
        }
    }

    private static func previousDayStamp(from stamp: Int) -> Int {
        let y = stamp / 10000
        let m = (stamp / 100) % 100
        let d = stamp % 100
        var comps   = DateComponents()
        comps.year  = y
        comps.month = m
        comps.day   = d
        let cal = Calendar.current
        guard let date = cal.date(from: comps),
              let prev = cal.date(byAdding: .day, value: -1, to: date) else {
            return stamp - 1
        }
        let py = cal.component(.year,  from: prev)
        let pm = cal.component(.month, from: prev)
        let pd = cal.component(.day,   from: prev)
        return py * 10000 + pm * 100 + pd
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Lifetime Stats
    // ═══════════════════════════════════════════════════════════════════

    struct LifetimeStats: Codable {
        var sessions: Int           = 0
        var totalScore: Int         = 0
        var totalSpins: Int         = 0
        var totalFusions: Int       = 0
        var bestCombo: Int          = 0
        var bestApexRaw: Int        = 0
        var questClears: Int        = 0
        var dailyWins: Int          = 0
        var longestDailyStreak: Int = 0
        var lastPlayed: Date?       = nil

        var bestSessionScore: Int   = 0

        var bestApexLabel: String {
            guard bestApexRaw > 0,
                  let tier = GlyphTier(rawValue: bestApexRaw) else { return "—" }
            return tier.labelText
        }

        var lastPlayedLabel: String {
            guard let date = lastPlayed else { return "—" }
            let fmt        = DateFormatter()
            fmt.dateFormat = "MMM dd, yyyy"
            fmt.locale     = Locale(identifier: "en_US")
            return fmt.string(from: date)
        }
    }

    private static let lifetimeKey = "DynEvo_LifetimeStats"

    static func loadLifetimeStats() -> LifetimeStats {
        guard let data  = UserDefaults.standard.data(forKey: lifetimeKey),
              let stats = try? JSONDecoder().decode(LifetimeStats.self, from: data)
        else { return LifetimeStats() }
        return stats
    }

    private static func saveLifetimeStats(_ stats: LifetimeStats) {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: lifetimeKey)
        }
    }

    /// Record the results of a finished session into persistent lifetime statistics.
    static func recordSession(
        mode: WarpMode,
        score: Int,
        spins: Int,
        fusions: Int,
        bestCombo: Int,
        apex: GlyphTier?,
        won: Bool
    ) {
        var stats          = loadLifetimeStats()
        stats.sessions    += 1
        stats.totalScore  += score
        stats.totalSpins  += spins
        stats.totalFusions += fusions
        stats.lastPlayed   = Date()

        if bestCombo > stats.bestCombo {
            stats.bestCombo = bestCombo
        }
        if let a = apex, a.rawValue > stats.bestApexRaw {
            stats.bestApexRaw = a.rawValue
        }
        if score > stats.bestSessionScore {
            stats.bestSessionScore = score
        }

        switch mode {
        case .questRun:
            if won { stats.questClears += 1 }

        case .dailyChallenge(let stamp):
            saveDailyBest(score: score, for: stamp)
            if won {
                stats.dailyWins += 1
                updateDailyStreak(won: true, stamp: stamp)
                let currentStreak = UserDefaults.standard.integer(forKey: dailyStreakKey)
                if currentStreak > stats.longestDailyStreak {
                    stats.longestDailyStreak = currentStreak
                }
            } else {
                updateDailyStreak(won: false, stamp: stamp)
            }

        case .timedBlitz:
            break
        }

        saveLifetimeStats(stats)
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Achievements
    // ═══════════════════════════════════════════════════════════════════

    struct Achievement {
        let id: String
        let title: String
        let detail: String
        let icon: String
        let isUnlocked: Bool
    }

    static func loadAchievements() -> [Achievement] {
        let s = loadLifetimeStats()
        let streak = dailyStreak
        return [
            Achievement(id: "first_fusion",   title: "First Spark",
                         detail: "Perform your first fusion",
                         icon: "⚡", isUnlocked: s.totalFusions >= 1),
            Achievement(id: "combo_5",         title: "Combo King",
                         detail: "Achieve a 5× combo chain",
                         icon: "🔥", isUnlocked: s.bestCombo >= 5),
            Achievement(id: "combo_8",         title: "Cascade Master",
                         detail: "Achieve an 8× combo chain",
                         icon: "💥", isUnlocked: s.bestCombo >= 8),
            Achievement(id: "ancient_reach",   title: "Ancient Seeker",
                         detail: "Evolve a symbol to Ancient tier",
                         icon: "🏺", isUnlocked: s.bestApexRaw >= GlyphTier.ancient.rawValue),
            Achievement(id: "mystic_reach",    title: "Mystic Adept",
                         detail: "Evolve a symbol to Mystic tier",
                         icon: "🔮", isUnlocked: s.bestApexRaw >= GlyphTier.mystic.rawValue),
            Achievement(id: "legendary_reach", title: "Legendary Hunter",
                         detail: "Evolve a symbol to Legendary tier",
                         icon: "⚔️", isUnlocked: s.bestApexRaw >= GlyphTier.legendary.rawValue),
            Achievement(id: "divine_reach",    title: "Divine Ascendant",
                         detail: "Evolve a symbol to Divine tier",
                         icon: "👑", isUnlocked: s.bestApexRaw >= GlyphTier.divine.rawValue),
            Achievement(id: "quest_10",        title: "Quest Warrior",
                         detail: "Clear 10 quest levels",
                         icon: "🗡", isUnlocked: s.questClears >= 10),
            Achievement(id: "quest_50",        title: "Quest Champion",
                         detail: "Clear 50 quest levels",
                         icon: "🏆", isUnlocked: s.questClears >= 50),
            Achievement(id: "daily_7",         title: "Daily Devotee",
                         detail: "Win 7 daily challenges",
                         icon: "📅", isUnlocked: s.dailyWins >= 7),
            Achievement(id: "daily_streak_5",  title: "Streak Blazer",
                         detail: "Reach a 5-day daily win streak",
                         icon: "🔥", isUnlocked: streak >= 5 || s.longestDailyStreak >= 5),
            Achievement(id: "score_10k",       title: "Score Master",
                         detail: "Score 10,000+ in a single session",
                         icon: "💎", isUnlocked: s.bestSessionScore >= 10000),
            Achievement(id: "spins_1000",      title: "Spin Veteran",
                         detail: "Perform 1,000 total spins",
                         icon: "🌀", isUnlocked: s.totalSpins >= 1000),
            Achievement(id: "fusions_500",     title: "Fusion Expert",
                         detail: "Perform 500 total fusions",
                         icon: "✨", isUnlocked: s.totalFusions >= 500),
        ]
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Strategy Tips
    // ═══════════════════════════════════════════════════════════════════

    static let strategyTips: [(title: String, body: String)] = [
        ("Fill Wisely",
         "On your first spin all 16 slots fill at once — a lucky opening can trigger massive chains."),
        ("Chain Reactions",
         "Fusions create empty slots. The next spin refills them, which can cascade into more fusions."),
        ("Lowest First",
         "The engine always fuses the LOWEST matching tier first, building upward for bigger combos."),
        ("Watch the Odds",
         "Orbital weights shift every time you reach a new apex. Higher tiers appear more often after breakthroughs."),
        ("Seed Floor",
         "Seed weight never drops below 10 %. Use this to plan — low tiers keep recycling into matches."),
        ("Combo Multiplier",
         "Each successive fusion in a single spin adds ×0.25 to the score multiplier. A 4-combo = ×2.0!"),
        ("Daily Challenge",
         "Daily challenges use fixed parameters. Try different strategies each day to beat your best."),
        ("Quest Budgeting",
         "In quest mode, every spin counts. Aim to create chain reactions rather than hoping for lucky draws."),
        ("Divine Bonus",
         "Divine fusions grant +1,500 bonus points on top of the base score — aim high!"),
        ("Read the Grid",
         "Count matching symbols before spinning. If two of a kind are already on the board, one more completes the set."),
    ]

    static func randomTip() -> (title: String, body: String) {
        strategyTips[Int.random(in: 0..<strategyTips.count)]
    }
}
