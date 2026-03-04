// NexusVault.swift — Core Data Model & Game Engine
import Foundation

// MARK: - NexusVault

/// The central game engine managing all state for a single play session.
/// Handles probability weights, grid state, fusion evaluation, scoring,
/// quest configuration, and persistent leaderboard data.
class NexusVault {

    // MARK: - Initial Weight Configuration

    /// Default orbital weight table used at the start of every session.
    /// Values represent relative draw probabilities (not strict percentages
    /// until normalized). Total sums to 100 for convenience.
    private static let defaultWeights: [GlyphTier: Double] = [
        .seedling: 40, .verdant: 20, .sapling: 15, .arbor: 10,
        .ancient:   7, .mystic:   5, .legendary:  2, .divine:   1
    ]

    // MARK: - Published Game State

    /// Current draw-probability weights for each tier.
    /// Modified by `shiftOrbitalWeights` whenever a new apex tier is achieved.
    private(set) var orbitalWeights: [GlyphTier: Double] = defaultWeights

    /// The highest tier ever produced by fusion in this session, if any.
    private(set) var apexTierReached: GlyphTier? = nil

    /// Cumulative score across all fusion rounds this session.
    private(set) var totalLuminance: Int = 0

    /// Number of fusions that occurred in the most recent spin cycle.
    private(set) var cascadeDepth: Int = 0

    /// The highest cascade (combo) depth ever reached in this session.
    private(set) var peakCascade: Int = 0

    /// Total number of spins executed this session.
    private(set) var spinCount: Int = 0

    /// Consecutive spin cycles that produced zero fusions.
    private(set) var dormantStreak: Int = 0

    /// Total number of individual fusion events performed this session.
    private(set) var totalFusionsPerformed: Int = 0

    /// Current 4×4 grid of 16 cells; nil values represent empty slots.
    private(set) var gridCells: [GlyphTier?] = []

    // MARK: - Quest Mode State

    /// Active gameplay mode for this session.
    private(set) var warpMode: WarpMode = .timedBlitz

    /// Remaining spins before quest failure (quest mode only).
    private(set) var questSpinsLeft: Int = 12

    /// Target tier required for quest completion.
    private(set) var questTarget: GlyphTier = .arbor

    /// Number of target-tier symbols required on the grid simultaneously.
    private(set) var questTargetCount: Int = 1

    // MARK: - Static Quest Configuration

    /// Full 100-level quest progression table.
    /// Each entry defines (spins budget, target tier, required count).
    static let questConfigs: [(spins: Int, target: GlyphTier, count: Int)] = {
        var c = [(spins: Int, target: GlyphTier, count: Int)]()
        for lv in 1...100 {
            let cfg: (Int, GlyphTier, Int)
            switch lv {
            // ── Phase 1: Arbor (Lv4) ──────────────────────────────────────
            case 1...3:   cfg = (15, .arbor, 1)
            case 4...6:   cfg = (14, .arbor, 2)
            case 7...9:   cfg = (13, .arbor, 3)
            case 10...12: cfg = (12, .arbor, 4)
            // ── Phase 2: Ancient (Lv5) ────────────────────────────────────
            case 13...15: cfg = (14, .ancient, 1)
            case 16...18: cfg = (13, .ancient, 1)
            case 19...21: cfg = (12, .ancient, 2)
            case 22...24: cfg = (11, .ancient, 2)
            case 25...28: cfg = (10, .ancient, 3)
            // ── Phase 3: Mystic (Lv6) ─────────────────────────────────────
            case 29...31: cfg = (14, .mystic, 1)
            case 32...34: cfg = (13, .mystic, 1)
            case 35...37: cfg = (12, .mystic, 2)
            case 38...40: cfg = (11, .mystic, 2)
            case 41...43: cfg = (10, .mystic, 3)
            case 44...46: cfg = (9,  .mystic, 3)
            case 47...48: cfg = (8,  .mystic, 4)
            // ── Phase 4: Legendary (Lv7) ──────────────────────────────────
            case 49...51: cfg = (14, .legendary, 1)
            case 52...54: cfg = (13, .legendary, 1)
            case 55...57: cfg = (12, .legendary, 1)
            case 58...60: cfg = (11, .legendary, 2)
            case 61...63: cfg = (10, .legendary, 2)
            case 64...66: cfg = (9,  .legendary, 2)
            case 67...69: cfg = (8,  .legendary, 3)
            case 70...72: cfg = (8,  .legendary, 3)
            // ── Phase 5: Divine (Lv8) ─────────────────────────────────────
            case 73...75: cfg = (15, .divine, 1)
            case 76...78: cfg = (14, .divine, 1)
            case 79...81: cfg = (13, .divine, 1)
            case 82...84: cfg = (12, .divine, 1)
            case 85...87: cfg = (11, .divine, 2)
            case 88...90: cfg = (10, .divine, 2)
            case 91...93: cfg = (9,  .divine, 2)
            case 94...96: cfg = (8,  .divine, 3)
            case 97...99: cfg = (7,  .divine, 3)
            case 100:     cfg = (6,  .divine, 3)
            default:      cfg = (6,  .divine, 3)
            }
            c.append((spins: cfg.0, target: cfg.1, count: cfg.2))
        }
        return c
    }()

    // MARK: - Session Configuration

    /// Configure the engine for a specific game mode and reset all session state.
    func configureWarpMode(_ mode: WarpMode) {
        warpMode = mode
        resetSession()
        if case .questRun(let lvl) = mode {
            let idx          = min(lvl - 1, NexusVault.questConfigs.count - 1)
            questSpinsLeft   = NexusVault.questConfigs[idx].spins
            questTarget      = NexusVault.questConfigs[idx].target
            questTargetCount = NexusVault.questConfigs[idx].count
        }
    }

    /// Reset all mutable session state back to starting values.
    func resetSession() {
        orbitalWeights       = NexusVault.defaultWeights
        apexTierReached      = nil
        totalLuminance       = 0
        cascadeDepth         = 0
        peakCascade          = 0
        spinCount            = 0
        dormantStreak        = 0
        totalFusionsPerformed = 0
        gridCells            = []
        questTargetCount     = 1
    }

    // MARK: - Spin Execution

    /// Execute one spin: fill all empty grid cells with randomly sampled glyphs.
    /// On first spin the entire grid is populated. Subsequent spins only fill
    /// slots left empty after fusion resolution.
    /// - Returns: The updated grid state after sampling.
    func executeSpin() -> [GlyphTier?] {
        spinCount += 1
        if case .questRun = warpMode { questSpinsLeft -= 1 }

        if gridCells.isEmpty {
            // First spin: fill all 16 slots
            gridCells = (0..<16).map { _ in sampleGlyph() }
        } else {
            // Subsequent spins: only replace nil (empty) slots
            for i in gridCells.indices where gridCells[i] == nil {
                gridCells[i] = sampleGlyph()
            }
        }
        return gridCells
    }

    /// Sample a single glyph tier using the current orbital weight table.
    /// Uses weighted random selection; falls back to `.seedling` on edge cases.
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

    // MARK: - Fusion Data Structures

    /// Describes a single 3-symbol fusion event within a cycle.
    struct FusionStep {
        /// The tier of the three consumed symbols
        let sourceTier: GlyphTier
        /// The tier of the resulting upgraded symbol
        let resultTier: GlyphTier
        /// Grid index of the tile that stays and upgrades
        let baseIndex: Int
        /// Grid indices of the two tiles consumed by the fusion
        let consumedIndices: [Int]
        /// Snapshot of the grid after this step has been applied
        let gridSnapshot: [GlyphTier?]
    }

    /// Summary of a complete fusion resolution cycle following one spin.
    struct FusionResult {
        /// New apex tier achieved this cycle, if any
        let newApex: GlyphTier?
        /// Total number of individual fusions that occurred
        let comboCount: Int
        /// Score earned during this cycle (combo-multiplied)
        let scoreGained: Int
        /// Final grid state after all fusions are resolved
        let updatedGrid: [GlyphTier?]
        /// Ordered list of fusion steps for sequential animation
        let steps: [FusionStep]
    }

    // MARK: - Fusion Resolution

    /// Resolve all possible fusions in the current grid, building an
    /// animation step list and accumulating score with combo multipliers.
    /// Always processes the lowest available tier first (chain reaction).
    /// - Returns: A `FusionResult` describing everything that happened.
    func runFusionCycle() -> FusionResult {
        var cells   = gridCells
        var combo   = 0
        var score   = 0
        var newApex: GlyphTier? = nil
        var steps: [FusionStep] = []

        while true {
            guard let ft = lowestFusableTier(in: cells) else { break }

            let idxs   = indicesOf(tier: ft, in: cells)
            let chosen = Array(idxs.shuffled().prefix(3))
            let rt     = ft.next ?? ft

            // Apply fusion: upgrade base cell, clear the two consumed cells
            var nc = cells
            nc[chosen[0]] = rt
            nc[chosen[1]] = nil
            nc[chosen[2]] = nil
            cells = nc

            combo += 1
            totalFusionsPerformed += 1

            steps.append(FusionStep(
                sourceTier:      ft,
                resultTier:      rt,
                baseIndex:       chosen[0],
                consumedIndices: [chosen[1], chosen[2]],
                gridSnapshot:    cells
            ))

            // Score = base score × combo multiplier + tier bonus
            let pts = computeFusionScore(tier: rt, comboDepth: combo)
            score += pts

            // Track if this fusion produced a new all-time high tier
            if let prev = apexTierReached {
                if rt.rawValue > prev.rawValue { newApex = rt }
            } else {
                newApex = rt
            }
        }

        // Commit final state to the model
        gridCells      = cells
        cascadeDepth   = combo
        if combo > peakCascade { peakCascade = combo }
        totalLuminance += score
        dormantStreak  = combo == 0 ? dormantStreak + 1 : 0

        if let apex = newApex {
            apexTierReached = apex
            shiftOrbitalWeights(newApex: apex)
        }

        return FusionResult(
            newApex:     newApex,
            comboCount:  combo,
            scoreGained: score,
            updatedGrid: cells,
            steps:       steps
        )
    }

    /// Calculate the score for a single fusion event.
    /// Score = (tier.baseScore + tier.bonusScore) × (1 + combo × 0.25)
    private func computeFusionScore(tier: GlyphTier, comboDepth: Int) -> Int {
        let base = Double(tier.rawValue * tier.rawValue * 20)
        let mult = 1.0 + Double(comboDepth) * 0.25
        var pts  = Int(base * mult)
        if tier == .legendary { pts += 500  }
        if tier == .divine    { pts += 1500 }
        return pts
    }

    // MARK: - Weight Management

    /// Shift orbital weights upward when a new apex tier is achieved.
    /// - The new apex tier and its successor receive increased draw probability.
    /// - Lower tiers are trimmed proportionally to maintain total weight balance.
    private func shiftOrbitalWeights(newApex: GlyphTier) {
        let h = newApex.rawValue
        var w = orbitalWeights

        // Boost the achieved apex tier by +3% (cap at 25%)
        w[newApex] = min((w[newApex] ?? 0) + 3.0, 25.0)

        // Boost the tier above apex by +2% (cap at 25%)
        if let hNext = GlyphTier(rawValue: h + 1) {
            w[hNext] = min((w[hNext] ?? 0) + 2.0, 25.0)
        } else {
            // At max tier: extra +2% goes back to apex
            w[newApex] = min((w[newApex] ?? 0) + 2.0, 25.0)
        }

        // Trim 5% total from lower tiers, starting from the highest lower tier
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

        // Clamp total to 100 by adjusting seedling as a safety valve
        let total = w.values.reduce(0, +)
        if abs(total - 100.0) > 0.01 {
            let diff    = 100.0 - total
            let current = w[.seedling] ?? 0
            w[.seedling] = max(current + diff, 10.0)
        }
        orbitalWeights = w
    }

    // MARK: - Grid Search Helpers

    /// Find the lowest tier that has three or more copies on the grid.
    private func lowestFusableTier(in cells: [GlyphTier?]) -> GlyphTier? {
        for t in GlyphTier.allCases {
            if cells.filter({ $0 == t }).count >= 3 { return t }
        }
        return nil
    }

    /// Return all grid indices occupied by a specific tier.
    private func indicesOf(tier: GlyphTier, in cells: [GlyphTier?]) -> [Int] {
        cells.indices.filter { cells[$0] == tier }
    }

    // MARK: - Grid Analysis

    /// Whether the current grid contains any immediately fusable group.
    var hasActiveFusion: Bool {
        lowestFusableTier(in: gridCells) != nil
    }

    /// The most-populated tier currently on the grid, or nil if the grid is empty.
    var dominantTier: GlyphTier? {
        let filled = gridCells.compactMap { $0 }
        guard !filled.isEmpty else { return nil }
        var counts = [GlyphTier: Int]()
        filled.forEach { counts[$0, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    /// Fractional progress toward the current quest goal (0.0 – 1.0).
    var questProgressFraction: Double {
        guard case .questRun = warpMode, questTargetCount > 0 else { return 0 }
        let current = gridCells.compactMap({ $0 })
                               .filter { $0.rawValue >= questTarget.rawValue }.count
        return min(Double(current) / Double(questTargetCount), 1.0)
    }

    /// Number of grid cells currently meeting or exceeding the quest target tier.
    var questTargetCountOnGrid: Int {
        gridCells.compactMap({ $0 }).filter { $0.rawValue >= questTarget.rawValue }.count
    }

    /// Remaining spin budget as a fraction of the starting allotment (0.0 – 1.0).
    var spinBudgetFraction: Double {
        guard case .questRun(let lvl) = warpMode, lvl >= 1 else { return 1 }
        let idx   = min(lvl - 1, NexusVault.questConfigs.count - 1)
        let total = Double(NexusVault.questConfigs[idx].spins)
        guard total > 0 else { return 0 }
        return max(0, Double(questSpinsLeft) / total)
    }

    // MARK: - End Condition Checks

    /// True when the quest goal is currently satisfied on the live grid.
    var isQuestComplete: Bool {
        if case .questRun = warpMode {
            return questTargetCountOnGrid >= questTargetCount
        }
        return false
    }

    /// True when the spin budget is exhausted and the quest goal is not met.
    var isQuestFailed: Bool {
        if case .questRun = warpMode {
            return questSpinsLeft <= 0 && !isQuestComplete
        }
        return false
    }

    /// Always false — timed blitz ends via elapsed time, not a grid condition.
    var isInfiniteGameOver: Bool { false }

    // MARK: - Debug / Display Helpers

    /// Multi-line string showing all tier weights formatted for compact HUD display.
    func weightDescription() -> String {
        GlyphTier.allCases.map { t in
            String(format: "Lv%d:%.1f%%", t.rawValue, orbitalWeights[t] ?? 0)
        }.joined(separator: " ")
    }

    /// Two-row formatted weight string split into lower and upper tier groups.
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

    // MARK: - Quest Progress Persistence

    private static let questProgressKey = "DynamicEvolution_QuestMaxLevel"

    /// Load the highest quest level the player has unlocked (minimum 1).
    static var savedQuestLevel: Int {
        let saved = UserDefaults.standard.integer(forKey: questProgressKey)
        return max(saved, 1)
    }

    /// Persist a quest level if it exceeds the currently saved maximum.
    static func saveQuestLevel(_ level: Int) {
        let current = UserDefaults.standard.integer(forKey: questProgressKey)
        if level > current {
            UserDefaults.standard.set(level, forKey: questProgressKey)
        }
    }

    // MARK: - Leaderboard (Timed Blitz)

    /// A single leaderboard entry persisted between sessions.
    struct LeaderboardEntry: Codable {
        let score: Int
        let apexTier: Int       // GlyphTier.rawValue
        let apexCount: Int
        let date: Date
    }

    private static let leaderboardKey = "DynamicEvolution_Leaderboard"

    /// Load and return the leaderboard sorted highest score first.
    static func loadLeaderboard() -> [LeaderboardEntry] {
        guard let data    = UserDefaults.standard.data(forKey: leaderboardKey),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data)
        else { return [] }
        return entries.sorted { $0.score > $1.score }
    }

    /// Append a new entry to the leaderboard, keeping only the top 10.
    static func saveToLeaderboard(score: Int, apexTier: GlyphTier?, apexCount: Int) {
        var entries = loadLeaderboard()
        let entry = LeaderboardEntry(
            score:     score,
            apexTier:  apexTier?.rawValue ?? 0,
            apexCount: apexCount,
            date:      Date()
        )
        entries.append(entry)
        entries.sort { $0.score > $1.score }
        if entries.count > 10 { entries = Array(entries.prefix(10)) }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: leaderboardKey)
        }
    }

    // MARK: - Grid Statistics

    /// Returns the highest tier currently on the grid along with its count,
    /// or nil if the grid is completely empty.
    func apexTierStats() -> (tier: GlyphTier, count: Int)? {
        let filled = gridCells.compactMap { $0 }
        guard !filled.isEmpty else { return nil }
        let highest = filled.max(by: { $0.rawValue < $1.rawValue })!
        let count   = filled.filter { $0 == highest }.count
        return (highest, count)
    }

    /// Returns a count of each tier currently present on the grid.
    func gridTierCounts() -> [GlyphTier: Int] {
        var counts = [GlyphTier: Int]()
        gridCells.compactMap({ $0 }).forEach { counts[$0, default: 0] += 1 }
        return counts
    }

    /// Number of non-empty cells currently on the grid.
    var filledCellCount: Int { gridCells.compactMap({ $0 }).count }

    /// Number of empty (nil) cells available for the next spin to fill.
    var emptyCellCount: Int { gridCells.filter({ $0 == nil }).count }
}
