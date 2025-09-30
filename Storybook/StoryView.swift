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

#Preview {
    StoryView(story: Story.example)
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
