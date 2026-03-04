// GameTypes.swift — Shared Game Types
import Foundation

enum GlyphTier: Int, CaseIterable {
    case seedling=1,verdant,sapling,arbor,ancient,mystic,legendary,divine
    var labelText: String {
        ["","Seed","Sprout","Sapling","Tree","Ancient","Mystic","Legendary","Divine"][rawValue]
    }
    var assetName: String {
        ["","symbol_lv1_seed","symbol_lv2_sprout","symbol_lv3_sapling","symbol_lv4_tree",
         "symbol_lv5_ancient","symbol_lv6_mystic","symbol_lv7_legendary","symbol_lv8_divine"][rawValue]
    }
    var next: GlyphTier? { GlyphTier(rawValue: rawValue+1) }
}

enum WarpMode { case questRun(level:Int), timedBlitz }
