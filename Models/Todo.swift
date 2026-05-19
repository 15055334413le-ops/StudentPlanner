//
//  Todo.swift
//  StudentPlanner
//
//  Todo model for task management
//

import SwiftUI

enum TodoCategory: String, Codable, CaseIterable {
    case study = "学习"
    case life = "生活"
    case work = "工作"
    case other = "其他"
    
    var color: Color {
        switch self {
        case .study: return .blue
        case .life: return .green
        case .work: return .orange
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .study: return "book.fill"
        case .life: return "house.fill"
        case .work: return "briefcase.fill"
        case .other: return "tag.fill"
        }
    }
}

struct Todo: Identifiable, Codable {
    let id: UUID
    var title: String
    var dueDate: Date?
    var category: TodoCategory
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    var notes: String?
    
    init(id: UUID = UUID(), title: String, dueDate: Date? = nil, category: TodoCategory = .other, isCompleted: Bool = false, notes: String? = nil) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.category = category
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.completedAt = isCompleted ? Date() : nil
        self.notes = notes
    }
    
    mutating func toggleComplete() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
    
    var dueDateString: String {
        guard let dueDate = dueDate else { return "无截止日期" }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDay = calendar.startOfDay(for: dueDate)
        
        if dueDay == today {
            return "今天"
        } else if dueDay == calendar.date(byAdding: .day, value: 1, to: today) {
            return "明天"
        } else if dueDay == calendar.date(byAdding: .day, value: -1, to: today) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            return formatter.string(from: dueDate)
        }
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    var priority: Priority {
        if isOverdue {
            return .high
        } else if let dueDate = dueDate {
            let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
            if daysUntilDue <= 1 {
                return .medium
            }
        }
        return .low
    }
}

enum Priority: Int {
    case low = 0
    case medium = 1
    case high = 2
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Sample Data
extension Todo {
    static func sampleTodos() -> [Todo] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            Todo(title: "完成数学作业", dueDate: today, category: .study),
            Todo(title: "预约图书馆座位", dueDate: calendar.date(byAdding: .day, value: 1, to: today), category: .life),
            Todo(title: "英语单词背诵", dueDate: today, category: .study, isCompleted: true),
            Todo(title: "准备期中考试", dueDate: calendar.date(byAdding: .day, value: 2, to: today), category: .study),
            Todo(title: "买生活用品", dueDate: calendar.date(byAdding: .day, value: 2, to: today), category: .life),
            Todo(title: "整理笔记", dueDate: calendar.date(byAdding: .day, value: -1, to: today), category: .study)
        ]
    }
}
