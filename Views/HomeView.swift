//
//  HomeView.swift
//  StudentPlanner
//
//  Home screen with upcoming class/event and todo list
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingAddTodo = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.spacing24) {
                    // Header
                    headerView
                    
                    // Upcoming Card
                    upcomingCard
                    
                    // Todo List Section
                    todoListSection
                }
                .padding(.horizontal, Layout.spacing16)
                .padding(.top, Layout.spacing8)
                .padding(.bottom, Layout.spacing100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView()
                    .environmentObject(appViewModel)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: Layout.spacing4) {
                Text(greeting)
                    .font(Typography.headline)
                    .foregroundColor(.secondary)
                
                Text(appViewModel.userProfile.name)
                    .font(Typography.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Avatar
            Circle()
                .fill(Color.primaryBlue.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(appViewModel.userProfile.name.prefix(1)))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                )
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "早上好 👋"
        case 12..<14: return "中午好 👋"
        case 14..<18: return "下午好 👋"
        default: return "晚上好 👋"
        }
    }
    
    // MARK: - Upcoming Card
    private var upcomingCard: some View {
        let upcoming = getUpcomingItem()
        
        return VStack(alignment: .leading, spacing: Layout.spacing16) {
            // Badge
            HStack {
                Image(systemName: "clock.fill")
                    .font(.caption)
                Text(upcomingBadgeText(for: upcoming))
                    .font(Typography.captionMedium)
                Spacer()
            }
            .foregroundColor(.white.opacity(0.9))
            
            // Content
            VStack(alignment: .leading, spacing: Layout.spacing8) {
                Text(upcoming?.title ?? "暂无 upcoming 事项")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                if let item = upcoming {
                    HStack(spacing: Layout.spacing16) {
                        if let location = item.location {
                            Label(location, systemImage: "mappin.fill")
                                .font(Typography.body)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        
                        Label(item.timeString, systemImage: "clock")
                            .font(Typography.body)
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
            }
            
            // Action Button
            if upcoming != nil {
                Button(action: {}) {
                    Text("查看详情")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, Layout.spacing16)
                        .padding(.vertical, Layout.spacing8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(Layout.cornerRadius8)
                }
                .padding(.top, Layout.spacing8)
            }
        }
        .padding(Layout.spacing20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.blue, Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Layout.cornerRadius16)
        .cardShadow()
    }
    
    // MARK: - Todo List Section
    private var todoListSection: some View {
        VStack(alignment: .leading, spacing: Layout.spacing16) {
            // Section Header
            HStack {
                Text("今日待办")
                    .font(Typography.title3)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(incompleteCount) 待完成")
                    .font(Typography.captionMedium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, Layout.spacing8)
                    .padding(.vertical, Layout.spacing4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(Layout.cornerRadius8)
            }
            
            // Todo Items
            LazyVStack(spacing: Layout.spacing12) {
                ForEach(sortedTodos) { todo in
                    TodoItemView(todo: todo) {
                        toggleTodo(todo)
                    }
                }
            }
        }
    }
    
    private var incompleteCount: Int {
        appViewModel.todos.filter { !$0.isCompleted }.count
    }
    
    private var sortedTodos: [Todo] {
        appViewModel.todos.sorted {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted
            }
            if let d1 = $0.dueDate, let d2 = $1.dueDate {
                return d1 < d2
            }
            return $0.dueDate != nil
        }
    }
    
    // MARK: - Helper Methods
    private func getUpcomingItem() -> UpcomingItem? {
        let calendar = Calendar.current
        let now = Date()
        
        // Get today's courses
        let weekday = calendar.component(.weekday, from: now)
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1 // Convert to 1=Monday
        
        let todayCourses = appViewModel.courses
            .filter { $0.dayOfWeek == adjustedWeekday }
            .sorted { $0.startTime < $1.startTime }
        
        // Find next course
        if let nextCourse = todayCourses.first(where: { course in
            let courseStart = calendar.date(bySettingHour: calendar.component(.hour, from: course.startTime),
                                           minute: calendar.component(.minute, from: course.startTime),
                                           second: 0,
                                           of: now) ?? now
            return courseStart > now
        }) {
            return UpcomingItem(
                title: nextCourse.name,
                location: nextCourse.location,
                timeString: nextCourse.timeRangeString,
                type: .course
            )
        }
        
        // Check for today's events
        let todayEvents = appViewModel.events
            .filter { calendar.isDate($0.date, inSameDayAs: now) }
            .sorted { e1, e2 in
                guard let t1 = e1.startTime, let t2 = e2.startTime else { return false }
                return t1 < t2
            }
        
        if let nextEvent = todayEvents.first(where: { event in
            guard let startTime = event.startTime else { return true }
            let eventStart = calendar.date(bySettingHour: calendar.component(.hour, from: startTime),
                                          minute: calendar.component(.minute, from: startTime),
                                          second: 0,
                                          of: now) ?? now
            return eventStart > now
        }) {
            return UpcomingItem(
                title: nextEvent.title,
                location: nextEvent.location,
                timeString: nextEvent.timeString,
                type: .event
            )
        }
        
        return nil
    }
    
    private func upcomingBadgeText(for item: UpcomingItem?) -> String {
        guard let item = item else { return "暂无事项" }
        switch item.type {
        case .course: return "即将开始"
        case .event: return " upcoming 日程"
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

// MARK: - Upcoming Item
struct UpcomingItem {
    let title: String
    let location: String?
    let timeString: String
    let type: ItemType
    
    enum ItemType {
        case course
        case event
    }
}

// MARK: - Todo Item View
struct TodoItemView: View {
    let todo: Todo
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: Layout.spacing12) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(todo.isCompleted ? .green : .gray.opacity(0.4))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content
            VStack(alignment: .leading, spacing: Layout.spacing4) {
                Text(todo.title)
                    .font(Typography.headline)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    .strikethrough(todo.isCompleted)
                
                HStack(spacing: Layout.spacing12) {
                    Label(todo.dueDateString, systemImage: "calendar")
                        .font(Typography.caption)
                        .foregroundColor(todo.isOverdue ? .red : .secondary)
                    
                    HStack(spacing: Layout.spacing4) {
                        Image(systemName: todo.category.icon)
                            .font(.system(size: 10))
                        Text(todo.category.rawValue)
                            .font(Typography.captionMedium)
                    }
                    .foregroundColor(todo.category.color)
                    .padding(.horizontal, Layout.spacing6)
                    .padding(.vertical, Layout.spacing2)
                    .background(todo.category.color.opacity(0.1))
                    .cornerRadius(4)
                }
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

// MARK: - Add Todo View
struct AddTodoView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var selectedCategory: TodoCategory = .study
    @State private var dueDate = Date()
    @State private var hasDueDate = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("任务信息") {
                    TextField("任务名称", text: $title)
                    
                    Picker("分类", selection: $selectedCategory) {
                        ForEach(TodoCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                Section("截止日期") {
                    Toggle("设置截止日期", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("截止日期", selection: $dueDate, displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle("新建待办")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTodo()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveTodo() {
        let todo = Todo(
            title: title,
            dueDate: hasDueDate ? dueDate : nil,
            category: selectedCategory
        )
        appViewModel.todos.append(todo)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}
