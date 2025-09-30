//
//  BookPagesView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-30.
//

import SwiftUI

struct BookPagesView: View {
    let story: Story
    
    var body: some View {
        ZStack {
            // Right page (content page)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.pageWhite)
                .frame(width: 280, height: 400)
                .overlay(
                    // Page content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(story.title)
                                .font(.system(size: 24, weight: .regular, design: .serif))
                                .foregroundColor(.black)
                            
                            Text(story.date, style: .date)
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(.gray)
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Text(story.text)
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(.black.opacity(0.8))
                                .lineSpacing(8)
                        }
                        .padding(30)
                    }
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: -5, y: 5)
            
            // Left page (back of cover - white)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.pageWhite)
                .frame(width: 280, height: 400)
                .offset(x: -285) // Position to the left
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 0)
        }
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        BookPagesView(story: Story.example)
    }
}
