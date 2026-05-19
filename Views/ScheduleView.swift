//
//  ScheduleView.swift
//  StudentPlanner
//
//  Weekly schedule view with course blocks
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedDay = Calendar.current.component(.weekday, from: Date())
    @State private var showingAddCourse = false
    
    private let hourHeight: CGFloat = 70
    private let startHour = 8
    private let endHour = 20
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Weekday Selector
                weekdaySelector
                
                Divider()
                
                // Schedule Grid
                ScrollView {
                    scheduleGrid
                        .padding(.top, Layout.spacing8)
                        .padding(.bottom, Layout.spacing100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("我的课表")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCourse = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
                    .environmentObject(appViewModel)
            }
        }
    }
    
    // MARK: - Weekday Selector
    private var weekdaySelector: some View {
        HStack(spacing: 0) {
            ForEach(1...7, id: \.self) { day in
                WeekdayButton(
                    day: day,
                    isSelected: selectedDay == day,
                    hasCourses: hasCourses(on: day)
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDay = day
                    }
                }
            }
        }
        .padding(.vertical, Layout.spacing12)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Schedule Grid
    private var scheduleGrid: some View {
        HStack(spacing: 0) {
            // Time Column
            timeColumn
            
            // Course Column
            courseColumn
        }
        .padding(.horizontal, Layout.spacing16)
    }
    
    private var timeColumn: some View {
        VStack(spacing: 0) {
            ForEach(startHour...endHour, id: \.self) { hour in
                Text("\(hour):00")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
                    .frame(height: hourHeight)
                    .frame(width: 50, alignment: .leading)
            }
        }
    }
    
    private var courseColumn: some View {
        ZStack(alignment: .topLeading) {
            // Grid Lines
            VStack(spacing: 0) {
                ForEach(startHour...endHour, id: \.self) { _ in
                    Divider()
                        .frame(height: hourHeight)
                }
            }
            
            // Course Blocks
            ForEach(coursesForSelectedDay) { course in
                CourseBlock(course: course, hourHeight: hourHeight, startHour: startHour)
            }
        }
        .frame(height: CGFloat(endHour - startHour + 1) * hourHeight)
    }
    
    // MARK: - Helper Methods
    private func hasCourses(on day: Int) -> Bool {
        let adjustedDay = day == 1 ? 7 : day - 1
        return appViewModel.courses.contains { $0.dayOfWeek == adjustedDay }
    }
    
    private var coursesForSelectedDay: [Course] {
        let adjustedDay = selectedDay == 1 ? 7 : selectedDay - 1
        return appViewModel.courses
            .filter { $0.dayOfWeek == adjustedDay }
            .sorted { $0.startTime < $1.startTime }
    }
}

// MARK: - Weekday Button
struct WeekdayButton: View {
    let day: Int
    let isSelected: Bool
    let hasCourses: Bool
    let action: () -> Void
    
    private var dayName: String {
        let days = ["日", "一", "二", "三", "四", "五", "六"]
        return days[day - 1]
    }
    
    private var dateNumber: String {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToAdd = day - weekday
        if let date = calendar.date(byAdding: .day, value: daysToAdd, to: today) {
            return String(calendar.component(.day, from: date))
        }
        return ""
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Layout.spacing4) {
                Text(dayName)
                    .font(Typography.captionMedium)
                
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .frame(width: 36, height: 36)
                    
                    Text(dateNumber)
                        .font(Typography.bodyMedium)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                // Indicator dot
                Circle()
                    .fill(hasCourses ? Color.blue : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .foregroundColor(isSelected ? .blue : .primary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Course Block
struct CourseBlock: View {
    let course: Course
    let hourHeight: CGFloat
    let startHour: Int
    
    private var offsetY: CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: course.startTime)
        let minute = calendar.component(.minute, from: course.startTime)
        let totalMinutes = (hour - startHour) * 60 + minute
        return CGFloat(totalMinutes) / 60.0 * hourHeight
    }
    
    private var height: CGFloat {
        let duration = course.durationInMinutes
        return CGFloat(duration) / 60.0 * hourHeight - 4
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing4) {
            Text(course.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(course.timeRangeString)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
            
            Text(course.location)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(Layout.spacing12)
        .frame(maxWidth: .infinity, maxHeight: height, alignment: .topLeading)
        .background(course.color)
        .cornerRadius(Layout.cornerRadius12)
        .shadow(color: course.color.opacity(0.3), radius: 4, x: 0, y: 2)
        .offset(y: offsetY)
        .padding(.trailing, Layout.spacing4)
    }
}

// MARK: - Add Course View
struct AddCourseView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var location = ""
    @State private var selectedDay = 1
    @State private var startTime = Date.from(hour: 8, minute: 0)
    @State private var endTime = Date.from(hour: 9, minute: 35)
    @State private var selectedColor: Color = .blue
    
    private let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .teal, .indigo]
    private let days = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("课程信息") {
                    TextField("课程名称", text: $name)
                    TextField("上课地点", text: $location)
                }
                
                Section("上课时间") {
                    Picker("星期", selection: $selectedDay) {
                        ForEach(1...7, id: \.self) { day in
                            Text(days[day - 1]).tag(day)
                        }
                    }
                    
                    DatePicker("开始时间", selection: $startTime, displayedComponents: [.hourAndMinute])
                    DatePicker("结束时间", selection: $endTime, displayedComponents: [.hourAndMinute])
                }
                
                Section("颜色标记") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(color.opacity(0.3), lineWidth: selectedColor == color ? 6 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, Layout.spacing8)
                }
            }
            .navigationTitle("添加课程")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveCourse()
                    }
                    .disabled(name.isEmpty || location.isEmpty)
                }
            }
        }
    }
    
    private func saveCourse() {
        let course = Course(
            name: name,
            location: location,
            dayOfWeek: selectedDay,
            startTime: startTime,
            endTime: endTime,
            color: selectedColor
        )
        appViewModel.courses.append(course)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    ScheduleView()
        .environmentObject(AppViewModel())
}
