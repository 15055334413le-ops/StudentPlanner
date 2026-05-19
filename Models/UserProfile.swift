//
//  UserProfile.swift
//  StudentPlanner
//
//  User profile model
//

import SwiftUI

struct UserProfile: Codable {
    var name: String
    var major: String
    var studentId: String
    var avatar: String?
    var email: String?
    var phone: String?
    
    static let `default` = UserProfile(
        name: "小明",
        major: "计算机科学",
        studentId: "2024001",
        avatar: nil,
        email: "xiaoming@example.com",
        phone: nil
    )
}

// MARK: - App Settings
struct AppSettings: Codable {
    var isDarkMode: Bool
    var isClassReminderEnabled: Bool
    var isEventReminderEnabled: Bool
    var reminderMinutesBefore: Int
    var themeColor: String
    
    static let `default` = AppSettings(
        isDarkMode: false,
        isClassReminderEnabled: true,
        isEventReminderEnabled: true,
        reminderMinutesBefore: 15,
        themeColor: "blue"
    )
}
