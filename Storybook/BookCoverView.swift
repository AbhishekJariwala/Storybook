//
//  BookCoverView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct BookCoverView: View {
    let title: String
    let subtitle: String
    
    private let userPrefs = UserPreferencesManager.shared
    
    var body: some View {
        ZStack {
            // Cover background with user's custom gradient
            RoundedRectangle(cornerRadius: 8)
                .fill(userPrefs.currentCoverGradient)
            
            // Cover content
            VStack(spacing: 8) {
                Spacer()
                
                Text(title)
                    .font(.system(size: 32, weight: .light, design: .serif))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.textSecondary)
                    .tracking(2)
                
                Spacer()
                
                // Small moon icon at bottom (like Yume)
                Image(systemName: "moonphase.first.quarter")
                    .font(.system(size: 24))
                    .foregroundColor(.accentGold)
                    .padding(.bottom, 40)
            }
            .padding()
        }
        .frame(maxWidth: 350) // MATCH STORY PAGE WIDTH
        .shadow(color: .black.opacity(0.5), radius: 20, x: -10, y: 10)
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        BookCoverView(title: "My Storybook", subtitle: "by You")
    }
}
