//
//  Theme.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-30.
//  Updated to clean minimalist iOS system colors
//

import SwiftUI

extension Color {
    // Clean minimalist theme - simple and elegant
    static let darkBackground = Color(hex: "#1C1C1E")  // Clean dark gray (iOS system dark)
    static let bookCover = Color(hex: "#2C2C2E")      // Slightly lighter gray for surfaces
    static let bookSpine = Color(hex: "#48484A")       // Medium gray for gradients
    static let pageWhite = Color(hex: "#FFFFFF")       // Pure white for pages
    static let textPrimary = Color(hex: "#FFFFFF")     // Clean white text
    static let textSecondary = Color(hex: "#8E8E93")  // System secondary gray
    static let accentGold = Color(hex: "#007AFF")     // iOS system blue (clean and professional)
    
    // Simplified accent colors
    static let accentCoral = Color(hex: "#FF3B30")    // System red
    static let accentTeal = Color(hex: "#34C759")     // System green
    static let accentPeriwinkle = Color(hex: "#5856D6") // System purple
    static let secondaryBackground = Color(hex: "#3A3A3C")  // Dark gray for surfaces
    static let hoverBackground = Color(hex: "#007AFF").opacity(0.15)  // Blue tint for hover states
    
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
