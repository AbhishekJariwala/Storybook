//
//  StorybookViewModel.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import Foundation
import SwiftUI

@MainActor
class StorybookViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var errorMessage: String?
    
    private let storageManager = StorageManager.shared
    
    init() {
        loadStories()
    }
    
    // MARK: - Load Stories
    func loadStories() {
        do {
            stories = try storageManager.loadStories()
            sortStories()
        } catch {
            errorMessage = "Failed to load stories: \(error.localizedDescription)"
            stories = []
        }
    }
    
    // MARK: - Create Story
    func addStory(_ story: Story) {
        stories.append(story)
        sortStories()
        saveStories()
    }
    
    // MARK: - Update Story
    func updateStory(_ story: Story) {
        if let index = stories.firstIndex(where: { $0.id == story.id }) {
            stories[index] = story
            sortStories()
            saveStories()
        }
    }
    
    // MARK: - Delete Story
    func deleteStory(_ story: Story) {
        stories.removeAll { $0.id == story.id }
        saveStories()
    }
    
    func deleteStory(at offsets: IndexSet) {
        stories.remove(atOffsets: offsets)
        saveStories()
    }
    
    // MARK: - Search Stories
    func searchStories(query: String) -> [Story] {
        guard !query.isEmpty else { return stories }
        
        return stories.filter { story in
            story.title.localizedCaseInsensitiveContains(query) ||
            story.text.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - Get Stories by Date
    func stories(for date: Date) -> [Story] {
        stories.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Private Helpers
    private func saveStories() {
        do {
            try storageManager.saveStories(stories)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save stories: \(error.localizedDescription)"
        }
    }
    
    private func sortStories() {
        stories.sort { $0.date > $1.date } // Most recent first
    }
}
