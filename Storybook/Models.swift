//
//  Models.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import Foundation

struct Story: Identifiable, Codable {
    let id: UUID
    var title: String
    var text: String
    var date: Date
    
    init(id: UUID = UUID(), title: String, text: String, date: Date = Date()) {
        self.id = id
        self.title = title
        self.text = text
        self.date = date
    }
}

// Extension for preview/testing data
extension Story {
    static let example = Story(
        title: "A Great Day",
        text: "Today was wonderful! I went for a walk in the park and saw the most beautiful sunset. The colors were incredible - oranges, pinks, and purples all blending together. It reminded me to appreciate the small moments.",
        date: Date()
    )
    
    static let examples = [
        Story(
            title: "Morning Coffee",
            text: "Started my day with a perfect cup of coffee. Sometimes it's the little things.",
            date: Date().addingTimeInterval(-86400)
        ),
        Story(
            title: "A Great Day",
            text: "Today was wonderful! I went for a walk in the park and saw the most beautiful sunset.",
            date: Date()
        ),
        Story(
            title: "Productive Work Session",
            text: "Finally finished that project I've been working on. Feels good to check it off the list.",
            date: Date().addingTimeInterval(-172800)
        )
    ]
}
