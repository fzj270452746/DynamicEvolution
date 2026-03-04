// NexusVault.swift — Core Data Model
import Foundation

class NexusVault {
    private(set) var orbitalWeights: [GlyphTier: Double] = [
        .seedling:40, .verdant:20, .sapling:15, .arbor:10,
        .ancient:7, .mystic:5, .legendary:2, .divine:1
    ]
    private(set) var apexTierReached: GlyphTier? = nil
    private(set) var totalLuminance: Int = 0
    private(set) var cascadeDepth: Int = 0
    private(set) var peakCascade: Int = 0
    private(set) var spinCount: Int = 0
    private(set) var dormantStreak: Int = 0
    private(set) var gridCells: [GlyphTier?] = []
    private(set) var warpMode: WarpMode = .timedBlitz
    private(set) var questSpinsLeft: Int = 12
    private(set) var questTarget: GlyphTier = .arbor
    private(set) var questTargetCount: Int = 1

    static let questConfigs: [(spins: Int, target: GlyphTier, count: Int)] = {
        var c = [(spins: Int, target: GlyphTier, count: Int)]()
        for lv in 1...100 {
            let cfg: (Int, GlyphTier, Int)
            switch lv {
            // ── Phase 1: Arbor (Lv4) ──
            case 1...3:   cfg = (15, .arbor, 1)
            case 4...6:   cfg = (14, .arbor, 2)
            case 7...9:   cfg = (13, .arbor, 3)
            case 10...12: cfg = (12, .arbor, 4)
            // ── Phase 2: Ancient (Lv5) ──
            case 13...15: cfg = (14, .ancient, 1)
            case 16...18: cfg = (13, .ancient, 1)
            case 19...21: cfg = (12, .ancient, 2)
            case 22...24: cfg = (11, .ancient, 2)
            case 25...28: cfg = (10, .ancient, 3)
            // ── Phase 3: Mystic (Lv6) ──
            case 29...31: cfg = (14, .mystic, 1)
            case 32...34: cfg = (13, .mystic, 1)
            case 35...37: cfg = (12, .mystic, 2)
            case 38...40: cfg = (11, .mystic, 2)
            case 41...43: cfg = (10, .mystic, 3)
            case 44...46: cfg = (9, .mystic, 3)
            case 47...48: cfg = (8, .mystic, 4)
            // ── Phase 4: Legendary (Lv7) ──
            case 49...51: cfg = (14, .legendary, 1)
            case 52...54: cfg = (13, .legendary, 1)
            case 55...57: cfg = (12, .legendary, 1)
            case 58...60: cfg = (11, .legendary, 2)
            case 61...63: cfg = (10, .legendary, 2)
            case 64...66: cfg = (9, .legendary, 2)
            case 67...69: cfg = (8, .legendary, 3)
            case 70...72: cfg = (8, .legendary, 3)
            // ── Phase 5: Divine (Lv8) ──
            case 73...75: cfg = (15, .divine, 1)
            case 76...78: cfg = (14, .divine, 1)
            case 79...81: cfg = (13, .divine, 1)
            case 82...84: cfg = (12, .divine, 1)
            case 85...87: cfg = (11, .divine, 2)
            case 88...90: cfg = (10, .divine, 2)
            case 91...93: cfg = (9, .divine, 2)
            case 94...96: cfg = (8, .divine, 3)
            case 97...99: cfg = (7, .divine, 3)
            case 100:     cfg = (6, .divine, 3)
            default:      cfg = (6, .divine, 3)
            }
            c.append((spins: cfg.0, target: cfg.1, count: cfg.2))
        }
        return c
    }()

    func configureWarpMode(_ mode: WarpMode) {
        warpMode = mode
        resetSession()
        if case .questRun(let lvl) = mode {
            let idx = min(lvl-1, NexusVault.questConfigs.count-1)
            questSpinsLeft    = NexusVault.questConfigs[idx].spins
            questTarget       = NexusVault.questConfigs[idx].target
            questTargetCount  = NexusVault.questConfigs[idx].count
        }
    }

    func resetSession() {
        orbitalWeights = [
            .seedling:40, .verdant:20, .sapling:15, .arbor:10,
            .ancient:7, .mystic:5, .legendary:2, .divine:1
        ]
        apexTierReached = nil
        totalLuminance  = 0
        cascadeDepth    = 0
        peakCascade     = 0
        spinCount       = 0
        dormantStreak   = 0
        gridCells       = []
        questTargetCount = 1
    }

    func executeSpin() -> [GlyphTier?] {
        spinCount += 1
        if case .questRun = warpMode { questSpinsLeft -= 1 }
        // Only fill nil (empty) slots; keep existing tiles untouched
        if gridCells.isEmpty {
            gridCells = (0..<16).map { _ in sampleGlyph() }
        } else {
            for i in gridCells.indices {
                if gridCells[i] == nil {
                    gridCells[i] = sampleGlyph()
                }
            }
        }
        return gridCells
    }

    private func sampleGlyph() -> GlyphTier {
        let total = orbitalWeights.values.reduce(0, +)
        var roll  = Double.random(in: 0..<total)
        for t in GlyphTier.allCases {
            let w = orbitalWeights[t] ?? 0
            if roll < w { return t }
            roll -= w
        }
        return .seedling
    }

    struct FusionStep {
        let sourceTier: GlyphTier
        let resultTier: GlyphTier
        let baseIndex: Int          // the one that stays and upgrades
        let consumedIndices: [Int]  // the two that get removed
        let gridSnapshot: [GlyphTier?] // grid state after this step
    }

    struct FusionResult {
        let newApex: GlyphTier?
        let comboCount: Int
        let scoreGained: Int
        let updatedGrid: [GlyphTier?]
        let steps: [FusionStep]
    }

    func runFusionCycle() -> FusionResult {
        var cells  = gridCells
        var combo  = 0
        var score  = 0
        var newApex: GlyphTier? = nil
        var steps: [FusionStep] = []

        while true {
            guard let ft = lowestFusableTier(in: cells) else { break }
            let idxs   = indicesOf(tier: ft, in: cells)
            let chosen = Array(idxs.shuffled().prefix(3))
            let rt     = ft.next ?? ft

            var nc = cells
            nc[chosen[0]] = rt
            nc[chosen[1]] = nil
            nc[chosen[2]] = nil
            cells = nc

            combo += 1

            steps.append(FusionStep(
                sourceTier: ft,
                resultTier: rt,
                baseIndex: chosen[0],
                consumedIndices: [chosen[1], chosen[2]],
                gridSnapshot: cells
            ))

            let base = Double(rt.rawValue * rt.rawValue * 20)
            let mult = 1.0 + Double(combo) * 0.25
            var pts  = Int(base * mult)
            if rt == .legendary { pts += 500 }
            if rt == .divine    { pts += 1500 }
            score += pts

            if let prev = apexTierReached {
                if rt.rawValue > prev.rawValue { newApex = rt }
            } else {
                newApex = rt
            }
        }

        gridCells      = cells
        cascadeDepth   = combo
        if combo > peakCascade { peakCascade = combo }
        totalLuminance += score
        dormantStreak  = combo == 0 ? dormantStreak + 1 : 0
        if let apex = newApex {
            apexTierReached = apex
            shiftOrbitalWeights(newApex: apex)
        }
        return FusionResult(newApex: newApex, comboCount: combo,
                            scoreGained: score, updatedGrid: cells,
                            steps: steps)
    }

    private func shiftOrbitalWeights(newApex: GlyphTier) {
        let h = newApex.rawValue
        var w = orbitalWeights

        // H +3%
        w[newApex] = min((w[newApex] ?? 0) + 3.0, 25.0)
        // H+1 +2% (if exists, otherwise give to H)
        if let hNext = GlyphTier(rawValue: h+1) {
            w[hNext] = min((w[hNext] ?? 0) + 2.0, 25.0)
        } else {
            w[newApex] = min((w[newApex] ?? 0) + 2.0, 25.0)
        }

        let lowers    = GlyphTier.allCases.filter { $0.rawValue < h }
        var remaining = 5.0
        for tier in lowers.reversed() {
            let cur      = w[tier] ?? 0
            let minVal: Double = tier == .seedling ? 10.0 : 0.5
            let canReduce = max(0, cur - minVal)
            let cut       = min(canReduce, remaining)
            w[tier]       = cur - cut
            remaining    -= cut
            if remaining <= 0 { break }
        }

        let total = w.values.reduce(0, +)
        if abs(total - 100.0) > 0.01 {
            let diff    = 100.0 - total
            let current = w[.seedling] ?? 0
            w[.seedling] = max(current + diff, 10.0)
        }
        orbitalWeights = w
    }

    private func lowestFusableTier(in cells: [GlyphTier?]) -> GlyphTier? {
        for t in GlyphTier.allCases {
            if cells.filter({ $0 == t }).count >= 3 { return t }
        }
        return nil
    }

    private func indicesOf(tier: GlyphTier, in cells: [GlyphTier?]) -> [Int] {
        cells.indices.filter { cells[$0] == tier }
    }

    var isQuestComplete: Bool {
        if case .questRun = warpMode {
            let matchCount = gridCells.compactMap({ $0 }).filter { $0.rawValue >= questTarget.rawValue }.count
            return matchCount >= questTargetCount
        }
        return false
    }

    var isQuestFailed: Bool {
        if case .questRun = warpMode { return questSpinsLeft <= 0 && !isQuestComplete }
        return false
    }

    var isInfiniteGameOver: Bool { return false }

    func weightDescription() -> String {
        GlyphTier.allCases.map { t in
            String(format: "Lv%d:%.1f%%", t.rawValue, orbitalWeights[t] ?? 0)
        }.joined(separator: " ")
    }

    // MARK: - Quest Progress Persistence
    private static let questProgressKey = "DynamicEvolution_QuestMaxLevel"

    static var savedQuestLevel: Int {
        let saved = UserDefaults.standard.integer(forKey: questProgressKey)
        return max(saved, 1)
    }

    static func saveQuestLevel(_ level: Int) {
        let current = UserDefaults.standard.integer(forKey: questProgressKey)
        if level > current {
            UserDefaults.standard.set(level, forKey: questProgressKey)
        }
    }

    // MARK: - Leaderboard (Timed Blitz)
    struct LeaderboardEntry: Codable {
        let score: Int
        let apexTier: Int       // rawValue
        let apexCount: Int
        let date: Date
    }

    private static let leaderboardKey = "DynamicEvolution_Leaderboard"

    static func loadLeaderboard() -> [LeaderboardEntry] {
        guard let data = UserDefaults.standard.data(forKey: leaderboardKey),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data)
        else { return [] }
        return entries.sorted { $0.score > $1.score }
    }

    static func saveToLeaderboard(score: Int, apexTier: GlyphTier?, apexCount: Int) {
        var entries = loadLeaderboard()
        let entry = LeaderboardEntry(
            score: score,
            apexTier: apexTier?.rawValue ?? 0,
            apexCount: apexCount,
            date: Date()
        )
        entries.append(entry)
        entries.sort { $0.score > $1.score }
        if entries.count > 10 { entries = Array(entries.prefix(10)) }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: leaderboardKey)
        }
    }

    /// Compute the highest tier and its count from current grid
    func apexTierStats() -> (tier: GlyphTier, count: Int)? {
        let filled = gridCells.compactMap { $0 }
        guard !filled.isEmpty else { return nil }
        let highest = filled.max(by: { $0.rawValue < $1.rawValue })!
        let count = filled.filter { $0 == highest }.count
        return (highest, count)
    }
}
