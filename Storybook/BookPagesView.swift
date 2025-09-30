//
//  BookPagesView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct BookPagesView: View {
    let story: Story
    
    var body: some View {
        ZStack {
            // Right page (content page)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.pageWhite)
                .frame(maxWidth: 350) // MATCH COVER WIDTH
                .overlay(
                    // Page content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(story.title)
                                .font(.system(size: 28, weight: .regular, design: .serif))
                                .foregroundColor(.black)
                            
                            Text(story.date, style: .date)
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(.gray)
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Text(story.text)
                                .font(.system(size: 17, design: .serif))
                                .foregroundColor(.black.opacity(0.8))
                                .lineSpacing(8)
                        }
                        .padding(30)
                    }
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: -5, y: 5)
        }
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        BookPagesView(story: Story.example)
    }
}
