//
//  StudentPlannerApp.swift
//  StudentPlanner
//
//  Main app entry point
//

import SwiftUI

@main
struct StudentPlannerApp: App {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}

// MARK: - App ViewModel
class AppViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var events: [Event] = []
    @Published var todos: [Todo] = []
    @Published var userProfile = UserProfile.default
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample courses
        courses = [
            Course(id: UUID(), name: "高等数学", location: "教学楼 A-301", dayOfWeek: 1, startTime: Date.from(hour: 8, minute: 0), endTime: Date.from(hour: 9, minute: 35), color: .blue),
            Course(id: UUID(), name: "大学英语", location: "教学楼 B-205", dayOfWeek: 1, startTime: Date.from(hour: 10, minute: 0), endTime: Date.from(hour: 11, minute: 35), color: .green),
            Course(id: UUID(), name: "计算机基础", location: "实验楼 C-102", dayOfWeek: 2, startTime: Date.from(hour: 14, minute: 0), endTime: Date.from(hour: 15, minute: 35), color: .purple),
            Course(id: UUID(), name: "线性代数", location: "教学楼 A-302", dayOfWeek: 3, startTime: Date.from(hour: 8, minute: 0), endTime: Date.from(hour: 9, minute: 35), color: .orange),
            Course(id: UUID(), name: "数据结构", location: "实验楼 C-201", dayOfWeek: 4, startTime: Date.from(hour: 10, minute: 0), endTime: Date.from(hour: 11, minute: 35), color: .pink),
            Course(id: UUID(), name: "物理学", location: "教学楼 D-101", dayOfWeek: 5, startTime: Date.from(hour: 14, minute: 0), endTime: Date.from(hour: 15, minute: 35), color: .teal)
        ]
        
        // Sample events
        let calendar = Calendar.current
        let today = Date()
        
        events = [
            Event(id: UUID(), title: "小组讨论", date: today, startTime: Date.from(hour: 14, minute: 0), endTime: Date.from(hour: 15, minute: 30), location: "图书馆", category: .study),
            Event(id: UUID(), title: "妈妈生日", date: calendar.date(byAdding: .day, value: 1, to: today) ?? today, startTime: nil, endTime: nil, location: nil, category: .life),
            Event(id: UUID(), title: "期中考试", date: calendar.date(byAdding: .day, value: 3, to: today) ?? today, startTime: Date.from(hour: 9, minute: 0), endTime: Date.from(hour: 11, minute: 0), location: "教学楼 A-301", category: .study)
        ]
        
        // Sample todos
        todos = [
            Todo(id: UUID(), title: "完成数学作业", dueDate: today, category: .study, isCompleted: false),
            Todo(id: UUID(), title: "预约图书馆座位", dueDate: calendar.date(byAdding: .day, value: 1, to: today), category: .life, isCompleted: false),
            Todo(id: UUID(), title: "英语单词背诵", dueDate: today, category: .study, isCompleted: true),
            Todo(id: UUID(), title: "准备期中考试", dueDate: calendar.date(byAdding: .day, value: 2, to: today), category: .study, isCompleted: false),
            Todo(id: UUID(), title: "买生活用品", dueDate: calendar.date(byAdding: .day, value: 2, to: today), category: .life, isCompleted: false)
        ]
    }
}

// MARK: - Helper Extensions
extension Date {
    static func from(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}
