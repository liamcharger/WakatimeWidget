//
//  StatsView.swift
//  WakatimeWidget
//
//  Created by Liam Willey on 1/29/25.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var wakaTimeService = WakaTimeService.shared
    
    @AppStorage("dateSelection") var dateSelection = 0
    
    var body: some View {
        NavigationStack {
            if let stats = wakaTimeService.stats {
                List {
                    Section {
                        VStack(spacing: 4) {
                            Text("Today's Stats")
                                .font(.system(size: 20).weight(.semibold))
                                .foregroundStyle(Color.gray)
                            Text(wakaTimeService.formatTime(wakaTimeService.seconds(from: stats)))
                                .font(.system(size: 42, design: .monospaced).weight(.bold))
                            if !stats.categories.isEmpty {
                                Text("You spent \(Int(wakaTimeService.seconds(from: stats)) / 3600) hours \(stats.categories.compactMap({ $0.key }).joined(separator: ", "))")
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.vertical, 26)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    Section("Projects") {
                        if stats.projects.isEmpty {
                            EmptyStateView()
                        } else {
                            ForEach(stats.projects, id: \.key) { project in
                                KeyRowView(project)
                            }
                        }
                    }
                    Section("Languages") {
                        if stats.languages.isEmpty {
                            EmptyStateView()
                        } else {
                            ForEach(stats.languages, id: \.key) { language in
                                KeyRowView(language)
                            }
                        }
                    }
                    Section("Editors") {
                        if stats.editors.isEmpty {
                            EmptyStateView()
                        } else {
                            ForEach(stats.editors, id: \.key) { editor in
                                KeyRowView(editor)
                            }
                        }
                    }
                    Section("Machines") {
                        if stats.machines.isEmpty {
                            EmptyStateView()
                        } else {
                            ForEach(stats.machines, id: \.key) { machine in
                                KeyRowView(machine)
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Stats")
            } else if wakaTimeService.apiKey.isEmpty {
                Text("Your WakaTime API key has not been set.")
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            } else {
                ProgressView("Pulling your stats...")
            }
        }
    }
}

struct KeyRowView: View {
    let key: WakaTimeStats.KeyValue
    
    let wakatimeService = WakaTimeService.shared
    
    init(_ key: WakaTimeStats.KeyValue) {
        self.key = key
    }
    
    var body: some View {
        HStack {
            Text(key.key)
                .fontWeight(.bold)
            Spacer()
            Text(wakatimeService.formatTime(Double(key.total)))
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        Text("There's nothing here...")
    }
}

#Preview {
    StatsView()
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
