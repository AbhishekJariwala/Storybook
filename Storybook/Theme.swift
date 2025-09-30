//
//  Theme.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-30.
//

import SwiftUI

extension Color {
    // Yume-inspired dark theme
    static let darkBackground = Color(hex: "#1A1A1A")
    static let bookCover = Color(hex: "#2D2D2D")
    static let bookSpine = Color(hex: "#242424")
    static let pageWhite = Color(hex: "#F5F1E8")
    static let textPrimary = Color(hex: "#E8E8E8")
    static let textSecondary = Color(hex: "#999999")
    static let accentGold = Color(hex: "#B8956A")
    
    // Helper to create colors from hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
