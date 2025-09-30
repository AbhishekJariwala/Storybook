//
//  LibraryView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: StorybookViewModel
    @State private var searchText = ""
    @State private var showingCalendar = false
    @State private var selectedDate: Date?
    @State private var selectedStory: Story?
    @State private var showingStoryDetail = false
    
    var filteredStories: [Story] {
        var stories = viewModel.stories
        
        // Filter by selected date if calendar mode and date is selected
        if showingCalendar, let date = selectedDate {
            stories = viewModel.stories(for: date)
        }
        
        // Filter by search text if search mode
        if !showingCalendar && !searchText.isEmpty {
            stories = stories.filter { story in
                story.title.localizedCaseInsensitiveContains(searchText) ||
                story.text.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return stories
    }
    
    // Group stories by month/year
    var groupedStories: [String: [Story]] {
        Dictionary(grouping: filteredStories) { story in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: story.date)
        }
    }
    
    var sortedGroupKeys: [String] {
        groupedStories.keys.sorted { key1, key2 in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            guard let date1 = formatter.date(from: key1),
                  let date2 = formatter.date(from: key2) else {
                return key1 > key2
            }
            return date1 > date2
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toggle between search and calendar
                Button {
                    showingCalendar.toggle()
                    // Clear filters when switching modes
                    if showingCalendar {
                        searchText = ""
                    } else {
                        selectedDate = nil
                    }
                } label: {
                    HStack {
                        Image(systemName: showingCalendar ? "magnifyingglass" : "calendar")
                        Text(showingCalendar ? "Show Search" : "Show Calendar")
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
                .padding(.top)
                .padding(.bottom, 8)
                
                if showingCalendar {
                    // Calendar View
                    CalendarView(
                        viewModel: viewModel,
                        selectedDate: $selectedDate
                    )
                    .frame(height: 400)
                } else {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search stories...", text: $searchText)
                            .textFieldStyle(.plain)
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                
                // List View (Always visible)
                if filteredStories.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: getEmptyStateIcon())
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text(getEmptyStateTitle())
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text(getEmptyStateSubtitle())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(sortedGroupKeys, id: \.self) { monthYear in
                            Section(header: Text(monthYear)) {
                                ForEach(groupedStories[monthYear] ?? []) { story in
                                    StoryRowView(story: story)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedStory = story
                                            showingStoryDetail = true
                                        }
                                }
                                .onDelete { indexSet in
                                    deleteStories(at: indexSet, in: monthYear)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedStory) { story in
                StoryDetailView(viewModel: viewModel, story: story)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func deleteStories(at offsets: IndexSet, in monthYear: String) {
        guard let stories = groupedStories[monthYear] else { return }
        for index in offsets {
            viewModel.deleteStory(stories[index])
        }
    }
    
    private func getEmptyStateIcon() -> String {
        if showingCalendar && selectedDate != nil {
            return "calendar.badge.exclamationmark"
        } else if !searchText.isEmpty {
            return "magnifyingglass"
        } else {
            return "book.closed"
        }
    }
    
    private func getEmptyStateTitle() -> String {
        if showingCalendar && selectedDate != nil {
            return "No stories on this date"
        } else if !searchText.isEmpty {
            return "No stories found"
        } else {
            return "No stories yet"
        }
    }
    
    private func getEmptyStateSubtitle() -> String {
        if showingCalendar && selectedDate != nil {
            return "Try selecting a different date"
        } else if !searchText.isEmpty {
            return "Try a different search term"
        } else {
            return "Start writing your first story"
        }
    }
}

struct StoryRowView: View {
    let story: Story
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail image if available
            if let firstImageData = story.imageData.first,
               let uiImage = UIImage(data: firstImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // Placeholder icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "book.pages")
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(story.text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(story.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct StoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StorybookViewModel
    let story: Story
    @State private var showingEditView = false
    
    var body: some View {
        NavigationStack {
            StoryView(story: story)
                .navigationTitle("Story")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") {
                            showingEditView = true
                        }
                    }
                }
                .sheet(isPresented: $showingEditView) {
                    AddEditStoryView(viewModel: viewModel, storyToEdit: story)
                }
        }
    }
}

#Preview {
    LibraryView(viewModel: StorybookViewModel())
}
