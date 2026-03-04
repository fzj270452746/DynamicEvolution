// GameTypes.swift — Shared Game Types & Tier Metadata
import UIKit

// MARK: - GlyphTier

/// Represents the eight evolution tiers of a glyph symbol.
/// Tiers progress from Seedling (Lv1) through Divine (Lv8).
/// Three matching symbols of the same tier fuse into the next tier.
enum GlyphTier: Int, CaseIterable, Comparable {
    case seedling = 1, verdant, sapling, arbor, ancient, mystic, legendary, divine

    // MARK: Display Text

    /// Full display name shown in HUD and result panels
    var labelText: String {
        ["", "Seed", "Sprout", "Sapling", "Tree", "Ancient", "Mystic", "Legendary", "Divine"][rawValue]
    }

    /// Asset image name for the tier's symbol sprite in Assets.xcassets
    var assetName: String {
        ["", "symbol_lv1_seed", "symbol_lv2_sprout", "symbol_lv3_sapling", "symbol_lv4_tree",
         "symbol_lv5_ancient", "symbol_lv6_mystic", "symbol_lv7_legendary",
         "symbol_lv8_divine"][rawValue]
    }

    /// Abbreviated 3-character label for compact HUD weight display
    var shortLabel: String { String(labelText.prefix(3)) }

    // MARK: Tier Progression

    /// The immediately higher tier, or nil if this is the maximum tier
    var next: GlyphTier? { GlyphTier(rawValue: rawValue + 1) }

    /// The immediately lower tier, or nil if this is the minimum tier
    var prev: GlyphTier? { GlyphTier(rawValue: rawValue - 1) }

    /// Whether this is the highest achievable tier (Divine)
    var isMaxTier: Bool { next == nil }

    /// Whether this tier is rarer than average (Ancient or higher)
    var isHighTier: Bool { rawValue >= GlyphTier.ancient.rawValue }

    // MARK: Scoring Values

    /// Base score awarded when fusing three symbols into this tier.
    /// Formula: rawValue² × 20
    var baseScore: Int { rawValue * rawValue * 20 }

    /// Additional bonus points for achieving rare high-tier fusions.
    /// Applied on top of baseScore during fusion calculation.
    var bonusScore: Int {
        switch self {
        case .legendary: return 500
        case .divine:    return 1500
        default:         return 0
        }
    }

    /// Total score for a single fusion resulting in this tier (base + bonus).
    /// Used by NexusVault when calculating combo-multiplied round scores.
    var fusionScore: Int { baseScore + bonusScore }

    // MARK: Visual Theme

    /// Primary UI color associated with this tier's visual identity.
    /// Used in tile borders, HUD labels, and particle effects.
    var themeColor: UIColor {
        switch self {
        case .seedling:  return UIColor(red: 0.55, green: 0.41, blue: 0.08, alpha: 1)
        case .verdant:   return UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1)
        case .sapling:   return UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1)
        case .arbor:     return UIColor(red: 0.11, green: 0.37, blue: 0.13, alpha: 1)
        case .ancient:   return UIColor(red: 1.00, green: 0.76, blue: 0.03, alpha: 1)
        case .mystic:    return UIColor(red: 0.42, green: 0.11, blue: 0.60, alpha: 1)
        case .legendary: return UIColor(red: 0.90, green: 0.32, blue: 0.00, alpha: 1)
        case .divine:    return UIColor(red: 1.00, green: 0.90, blue: 0.50, alpha: 1)
        }
    }

    // MARK: Comparable

    static func < (lhs: GlyphTier, rhs: GlyphTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - WarpMode

/// Gameplay mode controlling how a game session is configured.
/// Affects spin budgets, scoring methods, and end conditions.
enum WarpMode {

    /// Level-based quest: reach a target tier within a limited spin budget.
    case questRun(level: Int)

    /// Score attack: accumulate as many points as possible in 90 seconds.
    case timedBlitz

    // MARK: Mode Metadata

    /// Human-readable mode name for UI display
    var displayName: String {
        switch self {
        case .questRun(let lvl): return "Quest Lv.\(lvl)"
        case .timedBlitz:        return "Timed Blitz"
        }
    }

    /// Whether this mode imposes a finite spin budget on the player
    var hasLimitedSpins: Bool {
        if case .questRun = self { return true }
        return false
    }

    /// Quest level number, or nil when in timed blitz mode
    var questLevel: Int? {
        if case .questRun(let lvl) = self { return lvl }
        return nil
    }
}
