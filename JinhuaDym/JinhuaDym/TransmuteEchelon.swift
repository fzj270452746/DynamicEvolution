import UIKit

enum MorphRank: Int, CaseIterable, Comparable {
    case germinal = 1, verdure, juvenile, timber, primeval, arcane, fabled, celestial

    var designation: String {
        switch self {
        case .germinal:  return "Seed"
        case .verdure:   return "Sprout"
        case .juvenile:  return "Sapling"
        case .timber:    return "Tree"
        case .primeval:  return "Ancient"
        case .arcane:    return "Mystic"
        case .fabled:    return "Legendary"
        case .celestial: return "Divine"
        }
    }

    var iconAsset: String {
        switch self {
        case .germinal:  return "symbol_lv1_seed"
        case .verdure:   return "symbol_lv2_sprout"
        case .juvenile:  return "symbol_lv3_sapling"
        case .timber:    return "symbol_lv4_tree"
        case .primeval:  return "symbol_lv5_ancient"
        case .arcane:    return "symbol_lv6_mystic"
        case .fabled:    return "symbol_lv7_legendary"
        case .celestial: return "symbol_lv8_divine"
        }
    }

    var abbreviation: String { String(designation.prefix(3)) }
    var successor: MorphRank? { MorphRank(rawValue: rawValue + 1) }
    var predecessor: MorphRank? { MorphRank(rawValue: rawValue - 1) }
    var isCeiling: Bool { successor == nil }
    var isElite: Bool { rawValue >= MorphRank.primeval.rawValue }

    var inherentScore: Int { rawValue * rawValue * 20 }

    var supplementalScore: Int {
        switch self {
        case .fabled:    return 500
        case .celestial: return 1500
        default:         return 0
        }
    }

    var amalgamScore: Int { inherentScore + supplementalScore }

    var pigment: UIColor {
        switch self {
        case .germinal:  return UIColor(red: 0.55, green: 0.41, blue: 0.08, alpha: 1)
        case .verdure:   return UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1)
        case .juvenile:  return UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1)
        case .timber:    return UIColor(red: 0.11, green: 0.37, blue: 0.13, alpha: 1)
        case .primeval:  return UIColor(red: 1.00, green: 0.76, blue: 0.03, alpha: 1)
        case .arcane:    return UIColor(red: 0.42, green: 0.11, blue: 0.60, alpha: 1)
        case .fabled:    return UIColor(red: 0.90, green: 0.32, blue: 0.00, alpha: 1)
        case .celestial: return UIColor(red: 1.00, green: 0.90, blue: 0.50, alpha: 1)
        }
    }

    static func < (lhs: MorphRank, rhs: MorphRank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum SessionBlueprint {
    case odyssey(stage: Int)
    case chronoSurge
    case slotAscent

    var caption: String {
        switch self {
        case .odyssey(let s): return "Odyssey Stg.\(s)"
        case .chronoSurge:    return "Chrono Surge"
        case .slotAscent:     return "Slot Ascent"
        }
    }

    var hasFiniteMoves: Bool {
        if case .odyssey = self { return true }
        return false
    }

    var stageIndex: Int? {
        if case .odyssey(let s) = self { return s }
        return nil
    }
}
