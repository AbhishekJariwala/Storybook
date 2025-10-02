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
    
    // MARK: - Streak Tracking
    var currentStreak: Int {
        guard !stories.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get all unique dates when stories were written
        let storyDates = Set(stories.map { calendar.startOfDay(for: $0.date) })
        
        var streak = 0
        var currentDate = today
        
        // Count consecutive days backwards from today
        while storyDates.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        // If today has no story, don't count today but check if yesterday started a streak
        if !storyDates.contains(today) {
            currentDate = calendar.date(byAdding: .day, value: -1, to: today)!
            if storyDates.contains(currentDate) {
                streak = 0
                // Count backwards from yesterday
                while storyDates.contains(currentDate) {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                }
            }
        }
        
        return streak
    }
    
    var longestStreak: Int {
        guard !stories.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let storyDates = Set(stories.map { calendar.startOfDay(for: $0.date) }).sorted()
        
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<storyDates.count {
            let previousDate = storyDates[i - 1]
            let currentDate = storyDates[i]
            
            if calendar.dateComponents([.day], from: previousDate, to: currentDate).day == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    
    var streakEndDate: Date? {
        guard !stories.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let storyDates = Set(stories.map { calendar.startOfDay(for: $0.date) })
        
        var currentDate = today
        
        // If today has a story, the streak ends today
        if storyDates.contains(today) {
            return today
        }
        
        // Otherwise, find the last consecutive day
        currentDate = calendar.date(byAdding: .day, value: -1, to: today)!
        while storyDates.contains(currentDate) {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        // The streak ended one day before the first gap
        return calendar.date(byAdding: .day, value: 1, to: currentDate)
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
