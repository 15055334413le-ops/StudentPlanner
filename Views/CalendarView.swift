//
//  CalendarView.swift
//  StudentPlanner
//
//  Calendar view with monthly grid and events
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingAddEvent = false
    
    private let calendar = Calendar.current
    private let daysInWeek = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.spacing24) {
                    // Month Navigation
                    monthNavigation
                    
                    // Calendar Grid
                    calendarGrid
                    
                    // Selected Date Events
                    selectedDateSection
                }
                .padding(.horizontal, Layout.spacing16)
                .padding(.top, Layout.spacing8)
                .padding(.bottom, Layout.spacing100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("我的日程")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(selectedDate: selectedDate)
                    .environmentObject(appViewModel)
            }
        }
    }
    
    // MARK: - Month Navigation
    private var monthNavigation: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(Typography.title3)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: currentMonth)
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        VStack(spacing: Layout.spacing12) {
            // Weekday Headers
            HStack {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .font(Typography.captionMedium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: Layout.spacing8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasEvents: hasEvents(on: date)
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding(Layout.spacing16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Layout.cornerRadius16)
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let offsetDays = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Fill remaining cells
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    // MARK: - Selected Date Section
    private var selectedDateSection: some View {
        VStack(alignment: .leading, spacing: Layout.spacing16) {
            // Date Header
            HStack {
                Label(selectedDateString, systemImage: "calendar")
                    .font(Typography.title3)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Events List
            LazyVStack(spacing: Layout.spacing12) {
                ForEach(eventsForSelectedDate) { event in
                    EventItemView(event: event)
                }
                
                // Related Todos
                ForEach(todosForSelectedDate) { todo in
                    TodoItemView(todo: todo) {
                        toggleTodo(todo)
                    }
                }
            }
            
            if eventsForSelectedDate.isEmpty && todosForSelectedDate.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.plus",
                    title: "暂无日程",
                    subtitle: "点击右上角 + 添加新日程"
                )
                .padding(.top, Layout.spacing32)
            }
        }
    }
    
    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        let dateStr = formatter.string(from: selectedDate)
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        let weekdayStr = weekdayFormatter.string(from: selectedDate)
        
        return "\(dateStr) \(weekdayStr)"
    }
    
    private var eventsForSelectedDate: [Event] {
        appViewModel.events
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { e1, e2 in
                guard let t1 = e1.startTime, let t2 = e2.startTime else { return false }
                return t1 < t2
            }
    }
    
    private var todosForSelectedDate: [Todo] {
        appViewModel.todos
            .filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return calendar.isDate(dueDate, inSameDayAs: selectedDate)
            }
    }
    
    // MARK: - Helper Methods
    private func hasEvents(on date: Date) -> Bool {
        let hasEvents = appViewModel.events.contains { calendar.isDate($0.date, inSameDayAs: date) }
        let hasTodos = appViewModel.todos.contains { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
        return hasEvents || hasTodos
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func toggleTodo(_ todo: Todo) {
        if let index = appViewModel.todos.firstIndex(where: { $0.id == todo.id }) {
            var updatedTodo = todo
            updatedTodo.toggleComplete()
            appViewModel.todos[index] = updatedTodo
        }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    let action: () -> Void
    
    private var dayNumber: String {
        String(Calendar.current.component(.day, from: date))
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 40, height: 40)
                    
                    Text(dayNumber)
                        .font(Typography.bodyMedium)
                        .foregroundColor(textColor)
                }
                
                // Event indicator
                Circle()
                    .fill(hasEvents ? Color.blue : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(height: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue.opacity(0.1)
        }
        return Color.clear
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        }
        return .primary
    }
}

// MARK: - Event Item View
struct EventItemView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: Layout.spacing12) {
            // Icon
            ZStack {
                Circle()
                    .fill(event.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: event.category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(event.category.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: Layout.spacing4) {
                Text(event.title)
                    .font(Typography.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: Layout.spacing12) {
                    Label(event.timeString, systemImage: "clock")
                        .font(Typography.caption)
                        .foregroundColor(.secondary)
                    
                    if let location = event.location {
                        Label(location, systemImage: "mappin")
                            .font(Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: Layout.spacing4) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 10))
                    Text(event.category.rawValue)
                        .font(Typography.captionMedium)
                }
                .foregroundColor(event.category.color)
                .padding(.horizontal, Layout.spacing6)
                .padding(.vertical, Layout.spacing2)
                .background(event.category.color.opacity(0.1))
                .cornerRadius(4)
            }
            
            Spacer()
        }
        .padding(Layout.spacing16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Layout.cornerRadius12)
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cornerRadius12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Layout.spacing16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(title)
                .font(Typography.title3)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(Typography.body)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Add Event View
struct AddEventView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    let selectedDate: Date
    
    @State private var title = ""
    @State private var selectedCategory: EventCategory = .study
    @State private var startTime = Date.from(hour: 9, minute: 0)
    @State private var endTime = Date.from(hour: 10, minute: 0)
    @State private var location = ""
    @State private var isAllDay = false
    @State private var hasTime = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("日程信息") {
                    TextField("标题", text: $title)
                    
                    Picker("分类", selection: $selectedCategory) {
                        ForEach(EventCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                Section("时间") {
                    Toggle("全天", isOn: $isAllDay)
                    
                    if !isAllDay {
                        DatePicker("开始时间", selection: $startTime, displayedComponents: [.hourAndMinute])
                        DatePicker("结束时间", selection: $endTime, displayedComponents: [.hourAndMinute])
                    }
                }
                
                Section("地点") {
                    TextField("地点（可选）", text: $location)
                }
            }
            .navigationTitle("新建日程")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveEvent() {
        let event = Event(
            title: title,
            date: selectedDate,
            startTime: isAllDay ? nil : startTime,
            endTime: isAllDay ? nil : endTime,
            location: location.isEmpty ? nil : location,
            category: selectedCategory
        )
        appViewModel.events.append(event)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    CalendarView()
        .environmentObject(AppViewModel())
}
