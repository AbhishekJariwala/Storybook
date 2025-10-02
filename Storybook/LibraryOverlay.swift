//
//  LibraryOverlay.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-30.
//

import SwiftUI

struct LibraryOverlay: View {
    @ObservedObject var viewModel: StorybookViewModel
    @Binding var isPresented: Bool
    let onStorySelected: (Int) -> Void
    
    @State private var searchText = ""
    @State private var showingCalendar = false
    @State private var selectedDate: Date?
    @State private var isAppearing = false
    
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
            Color.black.opacity(isAppearing ? 0.5 : 0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
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
                    
                    // Minimal toggle buttons
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingCalendar = false
                                searchText = ""
                                selectedDate = nil
                            }
                        } label: {
                            Text("Search")
                                .font(.system(size: 14, weight: showingCalendar ? .light : .medium))
                                .foregroundColor(showingCalendar ? .textSecondary : .textPrimary)
                        }
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingCalendar = true
                                searchText = ""
                                selectedDate = nil
                            }
                        } label: {
                            Text("Calendar")
                                .font(.system(size: 14, weight: showingCalendar ? .medium : .light))
                                .foregroundColor(showingCalendar ? .textPrimary : .textSecondary)
                        }
                    }
                    .padding(.bottom, 24)
                    
                    if showingCalendar {
                        // Calendar View
                        CalendarView(
                            viewModel: viewModel,
                            selectedDate: $selectedDate
                        )
                        .background(Color.bookCover)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .frame(height: 350)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    } else {
                        // Clean search bar
                        HStack {
                            TextField("Search stories...", text: $searchText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.textPrimary)
                            
                            if !searchText.isEmpty {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        searchText = ""
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.bookCover)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                    
                    // Story list - Book cards style
                    if filteredStories.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: getEmptyStateIcon())
                                .font(.system(size: 40, weight: .thin))
                                .foregroundColor(.textSecondary)
                            
                            VStack(spacing: 8) {
                                Text(getEmptyStateTitle())
                                    .font(.system(size: 18, weight: .light, design: .serif))
                                    .foregroundColor(.textPrimary)
                                
                                Text(getEmptyStateSubtitle())
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(sortedGroupKeys, id: \.self) { monthYear in
                                    VStack(alignment: .leading, spacing: 16) {
                                        // Month header
                                        Text(monthYear)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.textSecondary)
                                            .textCase(.uppercase)
                                            .tracking(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 20)
                                        
                                        // Story cards
                                        VStack(spacing: 12) {
                                            ForEach(groupedStories[monthYear] ?? []) { story in
                                                if let index = viewModel.stories.firstIndex(where: { $0.id == story.id }) {
                                                    StoryCardView(story: story)
                                                        .contentShape(Rectangle())
                                                        .onTapGesture {
                                                            onStorySelected(index)
                                                        }
                                                        .transition(.scale.combined(with: .opacity))
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
                .frame(maxHeight: 700)
                .background(Color.darkBackground)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .scaleEffect(isAppearing ? 1.0 : 0.9)
                .opacity(isAppearing ? 1.0 : 0.0)
                .offset(y: isAppearing ? 0 : 100)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAppearing = true
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.2)) {
                isAppearing = false
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

// Book card-style story view
struct StoryCardView: View {
    let story: Story
    
    var body: some View {
        HStack(spacing: 16) {
            // Story thumbnail/cover
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.bookCover)
                    .frame(width: 60, height: 80)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                
                if let firstImageData = story.imageData.first,
                   let uiImage = UIImage(data: firstImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    // Book icon
                    Image(systemName: "book.pages")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.textSecondary)
                }
            }
            
            // Story details
            VStack(alignment: .leading, spacing: 6) {
                Text(story.title)
                    .font(.system(size: 16, weight: .light, design: .serif))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                Text(story.text)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                Spacer(minLength: 4)
                
                Text(story.date, style: .date)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            
            Spacer()
            
            // Subtle indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(.textSecondary.opacity(0.5))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.bookCover)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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