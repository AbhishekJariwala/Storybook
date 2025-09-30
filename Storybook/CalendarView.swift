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
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Month selector
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
                Spacer()
                
                Text(displayedMonth, format: .dateTime.month(.wide).year())
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            // Days of week header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            let days = generateDaysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
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
            
            Spacer()
        }
        .padding(.top)
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
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.body)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isCurrentMonth ? .primary : .secondary)
            
            if hasStories {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.3) : isToday ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
}

#Preview {
    CalendarView(viewModel: StorybookViewModel(), selectedDate: .constant(nil))
}
