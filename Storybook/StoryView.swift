//
//  DayView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct StoryView: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(story.title)
                .font(.title)
            
            Text(story.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(story.text)
                .font(.body)
            
            Spacer()
        }
        .padding()
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
