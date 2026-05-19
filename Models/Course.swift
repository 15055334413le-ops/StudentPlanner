//
//  Course.swift
//  StudentPlanner
//
//  Course model for schedule management
//

import SwiftUI

struct Course: Identifiable, Codable {
    let id: UUID
    var name: String
    var location: String
    var dayOfWeek: Int // 1 = Monday, 7 = Sunday
    var startTime: Date
    var endTime: Date
    var colorName: String
    
    var color: Color {
        Color(colorName)
    }
    
    init(id: UUID = UUID(), name: String, location: String, dayOfWeek: Int, startTime: Date, endTime: Date, color: Color) {
        self.id = id
        self.name = name
        self.location = location
        self.dayOfWeek = dayOfWeek
        self.startTime = startTime
        self.endTime = endTime
        self.colorName = color.description
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var durationInMinutes: Int {
        Int(duration / 60)
    }
    
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }
    
    var endTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: endTime)
    }
    
    var timeRangeString: String {
        "\(startTimeString)-\(endTimeString)"
    }
    
    var dayOfWeekString: String {
        let days = ["", "周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        return days[safe: dayOfWeek] ?? ""
    }
}

// MARK: - Sample Data
extension Course {
    static var sampleCourses: [Course] = [
        Course(name: "高等数学", location: "教学楼 A-301", dayOfWeek: 1, startTime: Date.from(hour: 8, minute: 0), endTime: Date.from(hour: 9, minute: 35), color: .blue),
        Course(name: "大学英语", location: "教学楼 B-205", dayOfWeek: 1, startTime: Date.from(hour: 10, minute: 0), endTime: Date.from(hour: 11, minute: 35), color: .green),
        Course(name: "计算机基础", location: "实验楼 C-102", dayOfWeek: 2, startTime: Date.from(hour: 14, minute: 0), endTime: Date.from(hour: 15, minute: 35), color: .purple),
        Course(name: "线性代数", location: "教学楼 A-302", dayOfWeek: 3, startTime: Date.from(hour: 8, minute: 0), endTime: Date.from(hour: 9, minute: 35), color: .orange),
        Course(name: "数据结构", location: "实验楼 C-201", dayOfWeek: 4, startTime: Date.from(hour: 10, minute: 0), endTime: Date.from(hour: 11, minute: 35), color: .pink),
        Course(name: "物理学", location: "教学楼 D-101", dayOfWeek: 5, startTime: Date.from(hour: 14, minute: 0), endTime: Date.from(hour: 15, minute: 35), color: .teal)
    ]
}

// MARK: - Safe Array Access
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
