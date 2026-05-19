//
//  ContentView.swift
//  StudentPlanner
//
//  Main content view with tab navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(0)
            
            // Schedule Tab
            ScheduleView()
                .tabItem {
                    Label("课表", systemImage: "book.fill")
                }
                .tag(1)
            
            // Calendar Tab
            CalendarView()
                .tabItem {
                    Label("日程", systemImage: "calendar")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .environmentObject(appViewModel)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
