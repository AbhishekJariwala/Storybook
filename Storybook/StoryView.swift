//
//  StoryView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct StoryView: View {
    let story: Story
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(story.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Date
                Text(story.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Images (if any)
                if !story.imageData.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(story.imageData.enumerated()), id: \.offset) { index, data in
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 300, height: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Story text
                Text(story.text)
                    .font(.body)
                    .lineSpacing(4)
                
                Spacer()
            }
            .padding()
        }
    }
}

// New themed version for the book view
struct ThemedStoryView: View {
    let story: Story
    
    var body: some View {
        // Book page look
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.pageWhite)
            .frame(maxWidth: 350)
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
            .overlay(
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text(story.title)
                            .font(.system(size: 28, weight: .regular, design: .serif))
                            .foregroundColor(.black)
                        
                        // Date
                        Text(story.date, style: .date)
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        Divider()
                            .background(Color.black.opacity(0.2))
                            .padding(.vertical, 4)
                        
                        // Images (if any)
                        if !story.imageData.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(story.imageData.enumerated()), id: \.offset) { index, data in
                                        if let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 250, height: 250)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Story text
                        Text(story.text)
                            .font(.system(size: 17, design: .serif))
                            .foregroundColor(.black.opacity(0.85))
                            .lineSpacing(10)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(32)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        ThemedStoryView(story: Story.example)
    }
}

#Preview("Multiple Stories") {
    ScrollView {
        VStack(spacing: 20) {
            ForEach(Story.examples) { story in
                StoryView(story: story)
            }
        }
    }
}
