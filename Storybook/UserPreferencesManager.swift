//
//  UserPreferencesManager.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-30.
//

import Foundation
import SwiftUI

class UserPreferencesManager: ObservableObject {
    static let shared = UserPreferencesManager()
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var bookTitle: String {
        didSet {
            UserDefaults.standard.set(bookTitle, forKey: "bookTitle")
        }
    }
    
    @Published var selectedCoverIndex: Int {
        didSet {
            UserDefaults.standard.set(selectedCoverIndex, forKey: "selectedCoverIndex")
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.bookTitle = UserDefaults.standard.string(forKey: "bookTitle") ?? "Dreams"
        self.selectedCoverIndex = UserDefaults.standard.integer(forKey: "selectedCoverIndex")
    }
    
    // Define cover gradient options (matching onboarding)
    var coverGradients: [LinearGradient] {
        [
            // Default purple/dreamy
            LinearGradient(colors: [Color(hex: "#1A1628"), Color(hex: "#2C2445")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Midnight blue
            LinearGradient(colors: [Color(hex: "#0D1421"), Color(hex: "#1E3A8A")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Deep forest
            LinearGradient(colors: [Color(hex: "#0F2B0F"), Color(hex: "#1B4332")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Wine red
            LinearGradient(colors: [Color(hex: "#2D0A0A"), Color(hex: "#7F1D1D")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Charcoal
            LinearGradient(colors: [Color(hex: "#1F1F23"), Color(hex: "#343439")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Indigo
            LinearGradient(colors: [Color(hex: "#1E1B4B"), Color(hex: "#4C1D95")], startPoint: .topLeading, endPoint: .bottomTrailing)
        ]
    }
    
    var currentCoverGradient: LinearGradient {
        guard selectedCoverIndex >= 0 && selectedCoverIndex < coverGradients.count else {
            return coverGradients[0] // Return default if index is invalid
        }
        return coverGradients[selectedCoverIndex]
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        bookTitle = "Dreams"
        selectedCoverIndex = 0
    }
}
