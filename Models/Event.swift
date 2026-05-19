//
//  Event.swift
//  StudentPlanner
//
//  Event model for calendar management
//

import SwiftUI

enum EventCategory: String, Codable, CaseIterable {
    case study = "学习"
    case life = "生活"
    case work = "工作"
    case entertainment = "娱乐"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .study: return "book.fill"
        case .life: return "house.fill"
        case .work: return "briefcase.fill"
        case .entertainment: return "gamecontroller.fill"
        case .other: return "tag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .study: return .blue
        case .life: return .green
        case .work: return .orange
        case .entertainment: return .purple
        case .other: return .gray
        }
    }
}

struct Event: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var location: String?
    var category: EventCategory
    var notes: String?
    
    init(id: UUID = UUID(), title: String, date: Date, startTime: Date? = nil, endTime: Date? = nil, location: String? = nil, category: EventCategory = .other, notes: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.category = category
        self.notes = notes
    }
    
    var isAllDay: Bool {
        startTime == nil && endTime == nil
    }
    
    var timeString: String {
        if isAllDay {
            return "全天"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if let start = startTime, let end = endTime {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        } else if let start = startTime {
            return formatter.string(from: start)
        }
        
        return ""
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - Sample Data
extension Event {
    static func sampleEvents() -> [Event] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            Event(title: "小组讨论", date: today, startTime: Date.from(hour: 14, minute: 0), endTime: Date.from(hour: 15, minute: 30), location: "图书馆", category: .study),
            Event(title: "妈妈生日", date: calendar.date(byAdding: .day, value: 1, to: today) ?? today, category: .life),
            Event(title: "期中考试", date: calendar.date(byAdding: .day, value: 3, to: today) ?? today, startTime: Date.from(hour: 9, minute: 0), endTime: Date.from(hour: 11, minute: 0), location: "教学楼 A-301", category: .study),
            Event(title: "社团活动", date: calendar.date(byAdding: .day, value: 2, to: today) ?? today, startTime: Date.from(hour: 18, minute: 30), endTime: Date.from(hour: 20, minute: 0), location: "活动中心", category: .entertainment)
        ]
    }
}
