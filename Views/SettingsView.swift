//
//  SettingsView.swift
//  StudentPlanner
//
//  Settings screen with user profile and app preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingProfileEdit = false
    @State private var showingLogoutConfirmation = false
    
    // Settings states
    @AppStorage("isClassReminderEnabled") private var isClassReminderEnabled = true
    @AppStorage("isEventReminderEnabled") private var isEventReminderEnabled = true
    @AppStorage("reminderMinutesBefore") private var reminderMinutesBefore = 15
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            List {
                // User Profile Section
                userProfileSection
                
                // Course Management Section
                courseManagementSection
                
                // Reminder Settings Section
                reminderSettingsSection
                
                // Appearance Section
                appearanceSection
                
                // Data Management Section
                dataManagementSection
                
                // About Section
                aboutSection
                
                // Logout Button
                logoutSection
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingProfileEdit) {
                EditProfileView()
                    .environmentObject(appViewModel)
            }
            .alert("确认退出", isPresented: $showingLogoutConfirmation) {
                Button("取消", role: .cancel) {}
                Button("退出", role: .destructive) {
                    // Handle logout
                }
            } message: {
                Text("确定要退出登录吗？")
            }
        }
    }
    
    // MARK: - User Profile Section
    private var userProfileSection: some View {
        Section {
            Button(action: { showingProfileEdit = true }) {
                HStack(spacing: Layout.spacing16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 60, height: 60)
                        
                        Text(String(appViewModel.userProfile.name.prefix(1)))
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: Layout.spacing4) {
                        Text(appViewModel.userProfile.name)
                            .font(Typography.title3)
                            .foregroundColor(.primary)
                        
                        Text(appViewModel.userProfile.major)
                            .font(Typography.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, Layout.spacing8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Course Management Section
    private var courseManagementSection: some View {
        Section(header: Text("课程管理").font(Typography.captionMedium)) {
            NavigationLink(destination: CourseListView()) {
                Label("课程列表", systemImage: "book.fill")
            }
            
            NavigationLink(destination: ClassTimeSettingsView()) {
                Label("上课时间设置", systemImage: "clock.fill")
            }
        }
    }
    
    // MARK: - Reminder Settings Section
    private var reminderSettingsSection: some View {
        Section(header: Text("提醒设置").font(Typography.captionMedium)) {
            Toggle(isOn: $isClassReminderEnabled) {
                Label("上课提醒", systemImage: "bell.fill")
            }
            
            if isClassReminderEnabled {
                NavigationLink(destination: ReminderTimeView(minutes: $reminderMinutesBefore)) {
                    HStack {
                        Label("提前提醒", systemImage: "clock.arrow.circlepath")
                        Spacer()
                        Text("\(reminderMinutesBefore) 分钟")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Toggle(isOn: $isEventReminderEnabled) {
                Label("日程提醒", systemImage: "calendar.badge.clock")
            }
        }
    }
    
    // MARK: - Appearance Section
    private var appearanceSection: some View {
        Section(header: Text("外观").font(Typography.captionMedium)) {
            Toggle(isOn: $isDarkMode) {
                Label("深色模式", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
            }
            
            NavigationLink(destination: ThemeColorView()) {
                Label("主题颜色", systemImage: "paintpalette.fill")
            }
        }
    }
    
    // MARK: - Data Management Section
    private var dataManagementSection: some View {
        Section(header: Text("数据管理").font(Typography.captionMedium)) {
            Button(action: exportData) {
                Label("导出数据", systemImage: "square.and.arrow.up.fill")
            }
            
            Button(action: importData) {
                Label("导入数据", systemImage: "square.and.arrow.down.fill")
            }
            
            Button(action: clearAllData) {
                Label("清除所有数据", systemImage: "trash.fill")
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        Section(header: Text("关于").font(Typography.captionMedium)) {
            HStack {
                Label("版本", systemImage: "info.circle.fill")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            Link(destination: URL(string: "https://example.com/privacy")!) {
                Label("隐私政策", systemImage: "hand.raised.fill")
            }
            
            Link(destination: URL(string: "https://example.com/terms")!) {
                Label("使用条款", systemImage: "doc.text.fill")
            }
            
            Button(action: sendFeedback) {
                Label("反馈建议", systemImage: "envelope.fill")
            }
        }
    }
    
    // MARK: - Logout Section
    private var logoutSection: some View {
        Section {
            Button(action: { showingLogoutConfirmation = true }) {
                Text("退出登录")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // MARK: - Actions
    private func exportData() {
        // Export data implementation
    }
    
    private func importData() {
        // Import data implementation
    }
    
    private func clearAllData() {
        // Clear data implementation
    }
    
    private func sendFeedback() {
        // Send feedback implementation
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var major = ""
    @State private var studentId = ""
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("姓名", text: $name)
                    TextField("专业", text: $major)
                    TextField("学号", text: $studentId)
                }
                
                Section("联系信息") {
                    TextField("邮箱", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveProfile()
                    }
                }
            }
            .onAppear {
                name = appViewModel.userProfile.name
                major = appViewModel.userProfile.major
                studentId = appViewModel.userProfile.studentId
                email = appViewModel.userProfile.email ?? ""
            }
        }
    }
    
    private func saveProfile() {
        appViewModel.userProfile.name = name
        appViewModel.userProfile.major = major
        appViewModel.userProfile.studentId = studentId
        appViewModel.userProfile.email = email.isEmpty ? nil : email
        dismiss()
    }
}

// MARK: - Course List View
struct CourseListView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        List {
            ForEach(appViewModel.courses) { course in
                CourseRow(course: course)
            }
            .onDelete(perform: deleteCourses)
        }
        .navigationTitle("课程列表")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteCourses(at offsets: IndexSet) {
        appViewModel.courses.remove(atOffsets: offsets)
    }
}

struct CourseRow: View {
    let course: Course
    
    var body: some View {
        HStack(spacing: Layout.spacing12) {
            // Color indicator
            Circle()
                .fill(course.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: Layout.spacing4) {
                Text(course.name)
                    .font(Typography.headline)
                
                Text("\(course.dayOfWeekString) \(course.timeRangeString) · \(course.location)")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, Layout.spacing4)
    }
}

// MARK: - Class Time Settings View
struct ClassTimeSettingsView: View {
    @AppStorage("classStartHour") private var classStartHour = 8
    @AppStorage("classEndHour") private var classEndHour = 20
    
    var body: some View {
        Form {
            Section("时间范围") {
                Stepper("开始时间: \(classStartHour):00", value: $classStartHour, in: 6...12)
                Stepper("结束时间: \(classEndHour):00", value: $classEndHour, in: 18...23)
            }
            
            Section("说明") {
                Text("设置课表显示的时间范围，方便查看课程安排。")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("上课时间设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reminder Time View
struct ReminderTimeView: View {
    @Binding var minutes: Int
    let options = [5, 10, 15, 30, 60]
    
    var body: some View {
        List {
            ForEach(options, id: \.self) { option in
                Button(action: { minutes = option }) {
                    HStack {
                        Text("\(option) 分钟")
                        Spacer()
                        if minutes == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("提前提醒时间")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Theme Color View
struct ThemeColorView: View {
    @AppStorage("themeColor") private var themeColor = "blue"
    
    let colors = [
        ("蓝色", "blue", Color.blue),
        ("绿色", "green", Color.green),
        ("紫色", "purple", Color.purple),
        ("橙色", "orange", Color.orange),
        ("粉色", "pink", Color.pink),
        ("红色", "red", Color.red)
    ]
    
    var body: some View {
        List {
            ForEach(colors, id: \.1) { name, key, color in
                Button(action: { themeColor = key }) {
                    HStack(spacing: Layout.spacing12) {
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                        
                        Text(name)
                        
                        Spacer()
                        
                        if themeColor == key {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("主题颜色")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
