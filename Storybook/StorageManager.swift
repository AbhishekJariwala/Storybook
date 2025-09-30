//
//  StorageManager.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let storiesFileName = "stories.json"
    
    private init() {}
    
    // Get the file URL for stories.json in Documents directory
    private var storiesFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(storiesFileName)
    }
    
    // Save stories to disk
    func saveStories(_ stories: [Story]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(stories)
        try data.write(to: storiesFileURL, options: .atomic)
    }
    
    // Load stories from disk
    func loadStories() throws -> [Story] {
        guard FileManager.default.fileExists(atPath: storiesFileURL.path) else {
            // No file exists yet, return empty array
            return []
        }
        
        let data = try Data(contentsOf: storiesFileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let stories = try decoder.decode([Story].self, from: data)
        return stories
    }
    
    // Delete all stories (useful for testing/debugging)
    func deleteAllStories() throws {
        if FileManager.default.fileExists(atPath: storiesFileURL.path) {
            try FileManager.default.removeItem(at: storiesFileURL)
        }
    }
}
