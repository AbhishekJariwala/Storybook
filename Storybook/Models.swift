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
    var imageData: [Data] // Array of image data
    
    init(id: UUID = UUID(), title: String, text: String, date: Date = Date(), imageData: [Data] = []) {
        self.id = id
        self.title = title
        self.text = text
        self.date = date
        self.imageData = imageData
    }
}

// Extension for preview/testing data
extension Story {
    static let example = Story(
        title: "A Great Day",
        text: "Today was wonderful! I went for a walk in the park and saw the most beautiful sunset. The colors were incredible - oranges, pinks, and purples all blending together. It reminded me to appreciate the small moments.",
        date: Date(),
        imageData: []
    )
    
    static let examples = [
        Story(
            title: "Morning Coffee",
            text: "Started my day with a perfect cup of coffee. Sometimes it's the little things.",
            date: Date().addingTimeInterval(-86400),
            imageData: []
        ),
        Story(
            title: "A Great Day",
            text: "Today was wonderful! I went for a walk in the park and saw the most beautiful sunset.",
            date: Date(),
            imageData: []
        ),
        Story(
            title: "Productive Work Session",
            text: "Finally finished that project I've been working on. Feels good to check it off the list.",
            date: Date().addingTimeInterval(-172800),
            imageData: []
        )
    ]
}
