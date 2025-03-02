//
//  ContentView.swift
//  WakatimeWidget
//
//  Created by Liam Willey on 1/22/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var wakaTimeService = WakaTimeService.shared
    
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Stats", systemImage: "chart.line.uptrend.xyaxis", value: 0) {
                StatsView()
            }
            Tab("Settings", systemImage: "gear", value: 1) {
                SettingsView()
            }
            .badge(wakaTimeService.apiKey.isEmpty ? 1 : 0)
        }
    }
}

#Preview {
    ContentView()
        .onAppear {
            WakaTimeService.shared.stats = WakaTimeStats(userId: "liamwilley", from: "dateFrom", to: "dateTo", projects: [
                WakaTimeStats.KeyValue(key: "my-project", total: 10899),
                WakaTimeStats.KeyValue(key: "my-project-1", total: 8240),
                WakaTimeStats.KeyValue(key: "my-project-2", total: 134),
            ], languages: [
                WakaTimeStats.KeyValue(key: "SwiftUI", total: 10899),
                WakaTimeStats.KeyValue(key: "React", total: 10899)
            ], editors: [
                WakaTimeStats.KeyValue(key: "Xcode", total: 10899),
                WakaTimeStats.KeyValue(key: "VS Code", total: 8240),
            ], operatingSystems: [], machines: [], labels: [], branches: [], entities: [], categories: [
                WakaTimeStats.KeyValue(key: "coding", total: 19273),
            ])
        }
}
