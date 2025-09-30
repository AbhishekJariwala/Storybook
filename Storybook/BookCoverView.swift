//
//  BookCoverView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-30.
//

import SwiftUI

struct BookCoverView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        ZStack {
            // Cover background with gradient
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color.bookCover, Color.bookSpine],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Cover content
            VStack(spacing: 8) {
                Spacer()
                
                Text(title)
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.textSecondary)
                    .tracking(2)
                
                Spacer()
                
                // Small moon icon at bottom (like Yume)
                Image(systemName: "moonphase.first.quarter")
                    .font(.system(size: 20))
                    .foregroundColor(.accentGold)
                    .padding(.bottom, 30)
            }
            .padding()
        }
        .frame(width: 280, height: 400)
        .shadow(color: .black.opacity(0.5), radius: 20, x: -10, y: 10)
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        BookCoverView(title: "Storybook", subtitle: "written by Abhi")
    }
}
