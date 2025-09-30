//
//  LibraryOverlay.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-30.
//


//
//  LibraryOverlay.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct LibraryOverlay: View {
    @ObservedObject var viewModel: StorybookViewModel
    @Binding var isPresented: Bool
    let onStorySelected: (Int) -> Void
    
    @State private var searchText = ""
    @State private var showingCalendar = false
    @State private var selectedDate: Date?
    
    var filteredStories: [Story] {
        var stories = viewModel.stories
        
        if showingCalendar, let date = selectedDate {
            stories = viewModel.stories(for: date)
        }
        
        if !showingCalendar && !searchText.isEmpty {
            stories = stories.filter { story in
                story.title.localizedCaseInsensitiveContains(searchText) ||
                story.text.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return stories
    }
    
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
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Library content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Handle bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.textSecondary.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    
                    // Toggle between search and calendar
                    Button {
                        showingCalendar.toggle()
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
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentGold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentGold.opacity(0.15))
                        .cornerRadius(8)
                    }
                    .padding(.bottom, 16)
                    
                    if showingCalendar {
                        // Calendar View
                        CalendarView(
                            viewModel: viewModel,
                            selectedDate: $selectedDate
                        )
                        .frame(height: 350)
                        .padding(.bottom, 16)
                    } else {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.textSecondary)
                            
                            TextField("Search stories...", text: $searchText)
                                .textFieldStyle(.plain)
                                .foregroundColor(.textPrimary)
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.bookCover)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    
                    // Story list
                    if filteredStories.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: getEmptyStateIcon())
                                .font(.system(size: 40, weight: .thin))
                                .foregroundColor(.textSecondary)
                            
                            Text(getEmptyStateTitle())
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(sortedGroupKeys, id: \.self) { monthYear in
                                    Section {
                                        ForEach(groupedStories[monthYear] ?? []) { story in
                                            if let index = viewModel.stories.firstIndex(where: { $0.id == story.id }) {
                                                StoryRowView(story: story)
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        onStorySelected(index)
                                                    }
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 8)
                                            }
                                        }
                                    } header: {
                                        Text(monthYear)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.textSecondary)
                                            .textCase(.uppercase)
                                            .tracking(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.top, 16)
                                            .padding(.bottom, 8)
                                            .background(Color.darkBackground)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 600)
                .background(Color.darkBackground)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
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
}

// Helper for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        LibraryOverlay(
            viewModel: StorybookViewModel(),
            isPresented: .constant(true),
            onStorySelected: { _ in }
        )
    }
}
