import Foundation

final class ApothicNucleus {

    private static let defaultDistribution: [MorphRank: Double] = [
        .germinal: 40, .verdure: 20, .juvenile: 15, .timber: 10,
        .primeval: 7,  .arcane: 5,   .fabled: 2,    .celestial: 1
    ]

    private(set) var distribution: [MorphRank: Double] = defaultDistribution
    private(set) var zenithRank: MorphRank?
    private(set) var cumulativePoints: Int = 0
    private(set) var chainDepth: Int = 0
    private(set) var peakChain: Int = 0
    private(set) var turnCount: Int = 0
    private(set) var inertStreak: Int = 0
    private(set) var totalAmalgamations: Int = 0
    private(set) var lattice: [MorphRank?] = []

    private(set) var blueprint: SessionBlueprint = .chronoSurge
    private(set) var odysseyTurnsLeft: Int = 12
    private(set) var odysseyObjective: MorphRank = .timber
    private(set) var odysseyRequiredCount: Int = 1

    // MARK: - Stage Manifest

    static let stageManifest: [(turns: Int, objective: MorphRank, quantity: Int)] = {
        let ladder: [(MorphRank, Int)] = [
            (.timber, 1),    (.timber, 2),    (.timber, 3),    (.primeval, 1),  (.timber, 4),
            (.primeval, 2),  (.timber, 5),    (.primeval, 3),  (.arcane, 1),    (.timber, 6),
            (.primeval, 4),  (.arcane, 2),    (.timber, 7),    (.primeval, 5),  (.arcane, 3),
            (.fabled, 1),    (.timber, 8),    (.primeval, 6),  (.arcane, 4),    (.fabled, 2),
            (.celestial, 1), (.timber, 9),    (.primeval, 7),  (.arcane, 5),    (.fabled, 3),
            (.celestial, 2), (.timber, 10),   (.primeval, 8),  (.arcane, 6),    (.fabled, 4),
            (.celestial, 3), (.timber, 11),   (.primeval, 9),  (.arcane, 7),    (.fabled, 5),
            (.timber, 12),   (.primeval, 10), (.arcane, 8),    (.fabled, 6),    (.celestial, 4),
        ]

        var m = [(turns: Int, objective: MorphRank, quantity: Int)]()

        for (i, e) in ladder.enumerated() {
            m.append((turns: 20 - i / 4, objective: e.0, quantity: e.1))
        }

        for j in 0..<30 {
            let e = ladder[10 + j]
            m.append((turns: max(15 - j / 3, 7), objective: e.0, quantity: e.1))
        }

        let rotated = Array(ladder[20..<40]) + Array(ladder[10..<20])
        for (j, e) in rotated.enumerated() {
            m.append((turns: max(12 - (j * 7) / 29, 5), objective: e.0, quantity: e.1))
        }

        return m
    }()

    // MARK: - Session

    func initializeBlueprint(_ mode: SessionBlueprint) {
        blueprint = mode
        purgeSession()
        if case .odyssey(let stg) = mode {
            let pos = min(stg - 1, Self.stageManifest.count - 1)
            odysseyTurnsLeft    = Self.stageManifest[pos].turns
            odysseyObjective    = Self.stageManifest[pos].objective
            odysseyRequiredCount = Self.stageManifest[pos].quantity
        }
    }

    func purgeSession() {
        distribution         = Self.defaultDistribution
        zenithRank           = nil
        cumulativePoints     = 0
        chainDepth           = 0
        peakChain            = 0
        turnCount            = 0
        inertStreak          = 0
        totalAmalgamations   = 0
        lattice              = []
        odysseyRequiredCount = 1
    }

    // MARK: - Turn

    @discardableResult
    func dispenseTurn() -> [MorphRank?] {
        turnCount += 1
        if case .odyssey = blueprint { odysseyTurnsLeft -= 1 }
        if lattice.isEmpty {
            lattice = (0..<16).map { _ in drawRank() }
        } else {
            for i in lattice.indices where lattice[i] == nil {
                lattice[i] = drawRank()
            }
        }
        return lattice
    }

    private func drawRank() -> MorphRank {
        let sum  = distribution.values.reduce(0, +)
        var dice = Double.random(in: 0..<sum)
        for rank in MorphRank.allCases {
            let w = distribution[rank] ?? 0
            if dice < w { return rank }
            dice -= w
        }
        return .germinal
    }

    // MARK: - Amalgamation

    struct AmalgamStep {
        let sourceRank: MorphRank
        let productRank: MorphRank
        let anchorIndex: Int
        let absorbedIndices: [Int]
        let snapshot: [MorphRank?]
    }

    struct AmalgamOutcome {
        let newZenith: MorphRank?
        let chainLength: Int
        let pointsEarned: Int
        let finalLattice: [MorphRank?]
        let steps: [AmalgamStep]
    }

    func resolveAmalgamations() -> AmalgamOutcome {
        var cells = lattice
        var chain = 0
        var pts = 0
        var freshZenith: MorphRank?
        var steps: [AmalgamStep] = []

        while let matchRank = lowestTriple(in: cells) {
            let positions = indicesMatching(rank: matchRank, in: cells)
            let selected  = Array(positions.shuffled().prefix(3))
            let product   = matchRank.successor ?? matchRank

            cells[selected[0]] = product
            cells[selected[1]] = nil
            cells[selected[2]] = nil

            chain += 1
            totalAmalgamations += 1

            steps.append(AmalgamStep(
                sourceRank: matchRank,
                productRank: product,
                anchorIndex: selected[0],
                absorbedIndices: [selected[1], selected[2]],
                snapshot: cells
            ))

            pts += computeReward(rank: product, depth: chain)

            if let prev = zenithRank {
                if product.rawValue > prev.rawValue { freshZenith = product }
            } else {
                freshZenith = product
            }
        }

        lattice      = cells
        chainDepth   = chain
        if chain > peakChain { peakChain = chain }
        cumulativePoints += pts
        inertStreak  = chain == 0 ? inertStreak + 1 : 0

        if let apex = freshZenith {
            zenithRank = apex
            recalibrateDistribution(newZenith: apex)
        }

        return AmalgamOutcome(
            newZenith: freshZenith,
            chainLength: chain,
            pointsEarned: pts,
            finalLattice: cells,
            steps: steps
        )
    }

    private func computeReward(rank: MorphRank, depth: Int) -> Int {
        let base = Double(rank.rawValue * rank.rawValue * 20)
        let mult = 1.0 + Double(depth) * 0.25
        var reward = Int(base * mult)
        if rank == .fabled    { reward += 500 }
        if rank == .celestial { reward += 1500 }
        return reward
    }

    // MARK: - Distribution

    private func recalibrateDistribution(newZenith: MorphRank) {
        let level = newZenith.rawValue
        var dist  = distribution

        dist[newZenith] = min((dist[newZenith] ?? 0) + 3.0, 25.0)

        if let higher = MorphRank(rawValue: level + 1) {
            dist[higher] = min((dist[higher] ?? 0) + 2.0, 25.0)
        } else {
            dist[newZenith] = min((dist[newZenith] ?? 0) + 2.0, 25.0)
        }

        let inferiors = MorphRank.allCases.filter { $0.rawValue < level }
        var surplus   = 5.0
        for rank in inferiors.reversed() {
            let cur       = dist[rank] ?? 0
            let floor: Double = rank == .germinal ? 10.0 : 0.5
            let reducible = max(0, cur - floor)
            let cut       = min(reducible, surplus)
            dist[rank]    = cur - cut
            surplus      -= cut
            if surplus <= 0 { break }
        }

        let aggregate = dist.values.reduce(0, +)
        if abs(aggregate - 100.0) > 0.01 {
            let delta = 100.0 - aggregate
            dist[.germinal] = max((dist[.germinal] ?? 0) + delta, 10.0)
        }
        distribution = dist
    }

    // MARK: - Lattice Queries

    private func lowestTriple(in cells: [MorphRank?]) -> MorphRank? {
        for rank in MorphRank.allCases {
            if cells.filter({ $0 == rank }).count >= 3 { return rank }
        }
        return nil
    }

    private func indicesMatching(rank: MorphRank, in cells: [MorphRank?]) -> [Int] {
        cells.indices.filter { cells[$0] == rank }
    }

    var hasActiveTriple: Bool { lowestTriple(in: lattice) != nil }

    var dominantRank: MorphRank? {
        let filled = lattice.compactMap { $0 }
        guard !filled.isEmpty else { return nil }
        var tally = [MorphRank: Int]()
        filled.forEach { tally[$0, default: 0] += 1 }
        return tally.max(by: { $0.value < $1.value })?.key
    }

    var objectiveCountOnLattice: Int {
        lattice.compactMap { $0 }.filter { $0.rawValue >= odysseyObjective.rawValue }.count
    }

    var odysseyProgressRatio: Double {
        guard case .odyssey = blueprint, odysseyRequiredCount > 0 else { return 0 }
        return min(Double(objectiveCountOnLattice) / Double(odysseyRequiredCount), 1.0)
    }

    var turnBudgetRatio: Double {
        guard case .odyssey(let stg) = blueprint, stg >= 1 else { return 1 }
        let pos   = min(stg - 1, Self.stageManifest.count - 1)
        let total = Double(Self.stageManifest[pos].turns)
        guard total > 0 else { return 0 }
        return max(0, Double(odysseyTurnsLeft) / total)
    }

    var isOdysseyAccomplished: Bool {
        if case .odyssey = blueprint { return objectiveCountOnLattice >= odysseyRequiredCount }
        return false
    }

    var isOdysseyForfeited: Bool {
        if case .odyssey = blueprint { return odysseyTurnsLeft <= 0 && !isOdysseyAccomplished }
        return false
    }

    // MARK: - Display

    func distributionRows() -> (upper: String, lower: String) {
        let all = MorphRank.allCases
        let upper = all.prefix(4).map {
            String(format: "%@:%.0f%%", $0.abbreviation, distribution[$0] ?? 0)
        }.joined(separator: "  ")
        let lower = all.suffix(4).map {
            String(format: "%@:%.0f%%", $0.abbreviation, distribution[$0] ?? 0)
        }.joined(separator: "  ")
        return (upper, lower)
    }

    // MARK: - Persistence

    private static let progressKey = "JinhuaDym_OdysseyPeak"

    static var preservedStage: Int {
        max(UserDefaults.standard.integer(forKey: progressKey), 1)
    }

    static func preserveStage(_ stage: Int) {
        if stage > UserDefaults.standard.integer(forKey: progressKey) {
            UserDefaults.standard.set(stage, forKey: progressKey)
        }
    }

    struct RankingEntry: Codable {
        let points: Int
        let zenithLevel: Int
        let zenithQuantity: Int
        let timestamp: Date
    }

    private static let rankingKey = "JinhuaDym_Rankings"

    static func fetchRankings() -> [RankingEntry] {
        guard let data = UserDefaults.standard.data(forKey: rankingKey),
              let entries = try? JSONDecoder().decode([RankingEntry].self, from: data)
        else { return [] }
        return entries.sorted { $0.points > $1.points }
    }

    static func archiveRanking(points: Int, zenithRank: MorphRank?, zenithQuantity: Int) {
        var entries = fetchRankings()
        entries.append(RankingEntry(
            points: points,
            zenithLevel: zenithRank?.rawValue ?? 0,
            zenithQuantity: zenithQuantity,
            timestamp: Date()
        ))
        entries.sort { $0.points > $1.points }
        if entries.count > 10 { entries = Array(entries.prefix(10)) }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: rankingKey)
        }
    }

    func zenithStatistics() -> (rank: MorphRank, quantity: Int)? {
        let filled = lattice.compactMap { $0 }
        guard !filled.isEmpty else { return nil }
        let highest = filled.max(by: { $0.rawValue < $1.rawValue })!
        return (highest, filled.filter { $0 == highest }.count)
    }

    var occupiedCells: Int { lattice.compactMap { $0 }.count }
    var vacantCells: Int   { lattice.filter { $0 == nil }.count }
}
