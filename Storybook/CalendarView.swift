//
//  CalendarView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: StorybookViewModel
    @Binding var selectedDate: Date?
    @State private var displayedMonth = Date()
    @State private var showingStoriesForDate = false
    @State private var storiesForSelectedDate: [Story] = []
    
    let onStorySelected: ((Int) -> Void)?
    
    // Initialize with optional callback
    init(viewModel: StorybookViewModel, selectedDate: Binding<Date?>, onStorySelected: ((Int) -> Void)? = nil) {
        self.viewModel = viewModel
        self._selectedDate = selectedDate
        self.onStorySelected = onStorySelected
    }
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Month selector
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Text(displayedMonth, format: .dateTime.month(.wide).year())
                    .font(.system(size: 16, weight: .light, design: .serif))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal)
            
            // Days of week header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            let days = generateDaysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            hasStories: hasStories(on: date),
                            isCurrentMonth: isDateInCurrentMonth(date),
                            isToday: calendar.isDateInToday(date),
                            isSelected: isDateSelected(date)
                        )
                        .onTapGesture {
                            handleDateTap(date)
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal)
            
            // Story selection for selected date
            if selectedDate != nil && hasStories(on: selectedDate!) {
                dateStoriesView
            }
        }
        .padding(.top)
    }
    
    // MARK: - Date Stories View
    private var dateStoriesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stories for \(selectedDate!, style: .date)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.stories(for: selectedDate!)) { story in
                        if let index = viewModel.stories.firstIndex(where: { $0.id == story.id }) {
                            Button {
                                onStorySelected?(index)
                                selectedDate = nil
                            } label: {
                                HStack(spacing: 8) {
                                    // Story thumbnail
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.bookCover)
                                            .frame(width: 32, height: 44)
                                        
                                        if let firstImageData = story.imageData.first,
                                           let uiImage = UIImage(data: firstImageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 32, height: 44)
                                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                        } else {
                                            Image(systemName: "book.pages")
                                                .font(.system(size: 12, weight: .light))
                                                .foregroundColor(.textSecondary)
                                        }
                                    }
                                    
                                    // Story title
                                    Text(story.title)
                                        .font(.system(size: 13, weight: .light, design: .serif))
                                        .foregroundColor(.textPrimary)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color.bookCover)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Helper Methods
    
    private func generateDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        let monthLastDay = calendar.date(byAdding: DateComponents(day: -1), to: monthInterval.end)!
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate <= monthLastDay {
            if calendar.isDate(currentDate, equalTo: displayedMonth, toGranularity: .month) {
                days.append(currentDate)
            } else if days.isEmpty || currentDate < monthInterval.start {
                days.append(nil) // Empty cells before month starts
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Fill remaining cells to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasStories(on date: Date) -> Bool {
        !viewModel.stories(for: date).isEmpty
    }
    
    private func isDateInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
    
    private func handleDateTap(_ date: Date) {
        // Toggle selection - if same date tapped, deselect
        if let currentSelection = selectedDate,
           calendar.isDate(currentSelection, inSameDayAs: date) {
            selectedDate = nil
        } else {
            selectedDate = date
        }
    }
}

struct DayCell: View {
    let date: Date
    let hasStories: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(textColor)
            
            if hasStories {
                Circle()
                    .fill(Color.accentGold)
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 36)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)
        )
    }
    
    private var textColor: Color {
        if isSelected {
            return .accentGold
        } else if isToday {
            return .textPrimary
        } else if isCurrentMonth {
            return .textPrimary
        } else {
            return .textSecondary.opacity(0.5)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .accentGold.opacity(0.15)
        } else if isToday {
            return .accentGold.opacity(0.08)
        } else {
            return .clear
        }
    }
}

#Preview {
    CalendarView(viewModel: StorybookViewModel(), selectedDate: .constant(nil))
}
