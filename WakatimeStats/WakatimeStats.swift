//
//  WakatimeStats.swift
//  WakatimeStats
//
//  Created by Liam Willey on 1/22/25.
//

import WidgetKit
import SwiftUI

struct WakaTimeStats: Decodable {
    let userId: String
    let from: String
    let to: String
    let projects: [KeyValue]
    let languages: [KeyValue]
    let editors: [KeyValue]
    let operatingSystems: [KeyValue]
    let machines: [KeyValue]
    let labels: [KeyValue]
    let branches: [String]?
    let entities: [String]?
    let categories: [KeyValue]
    
    struct KeyValue: Decodable {
        let key: String
        let total: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case from
        case to
        case projects
        case languages
        case editors
        case operatingSystems = "operating_systems"
        case machines
        case labels
        case categories
        case branches
        case entities
    }
}

class WakaTimeService {
    static let shared = WakaTimeService()
    
    private let userDefaults = UserDefaults(suiteName: "group.com.liamwilley.WakatimeWidget")
    private let apiKeyString = "wakaTimeApiKey"
    private var apiKey = ""
    private let apiUrl = "https://waka.hackclub.com/api/summary?interval=today"
    
    init() {
        apiKey = userDefaults?.string(forKey: apiKeyString) ?? ""
    }
    
    func fetchHours(completion: @escaping (WakaTimeStats?) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
        
        print("Fetching stats from: \(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            print("Widget response: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            do {
                let decoder = JSONDecoder()
                let stats = try decoder.decode(WakaTimeStats.self, from: data)
                completion(stats)
            } catch {
                print("Failed to decode stats: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchStats(completion: @escaping (WakaTimeStats?) -> Void) {
        fetchHours { stats in
            completion(stats)
        }
    }
}

struct Provider: TimelineProvider {
    let service = WakaTimeService.shared
    
    func placeholder(in context: Context) -> WakaTimeEntry {
        WakaTimeEntry(date: Date(), stats: nil) // TODO: update with dummy data
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WakaTimeEntry) -> Void) {
        service.fetchStats { stats in
            completion(WakaTimeEntry(date: Date(), stats: stats))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WakaTimeEntry>) -> Void) {
        service.fetchStats { stats in
            let entry = WakaTimeEntry(date: Date(), stats: stats)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 15))) // Check for new stats every fifteen minutes
            completion(timeline)
        }
    }
}

struct WakaTimeEntry: TimelineEntry {
    let date: Date
    let stats: WakaTimeStats?
}

struct WakatimeStatsEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            if let stats = entry.stats {
                statsView(stats)
            } else {
                // TODO: add better loading view
                Text("Loading your stats...")
                    .fontWeight(.medium)
                    .foregroundStyle(.primary.opacity(0.8))
            }
        }
    }
    
    private func statsView(_ stats: WakaTimeStats) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Today")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text("\(formatTime(seconds(from: stats)))")
                    .font(.system(size: 24).weight(.bold))
            }
            if stats.projects.isEmpty {
                Text("No projects")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(stats.projects.filter({ $0.key != "unknown" }).prefix(2), id: \.key) { project in
                        VStack(alignment: .leading) {
                            Text("\(project.key)").fontWeight(.semibold)
                            Text("\(formatTime(Double(project.total)))")
                                .foregroundStyle(.primary.opacity(0.8))
                        }
                        .font(.system(size: 14))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func seconds(from stats: WakaTimeStats) -> Double {
        return stats.categories.reduce(0.0) { $0 + Double($1.total) }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

struct WakatimeStats: Widget {
    let kind: String = "WakatimeStats"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WakatimeStatsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("WakaTime Stats")
        .description("Quickly glance your coding stats from WakaTime.")
        .supportedFamilies([.systemSmall]) // TODO: update UI to work with more sizes
    }
}

#Preview(as: .systemSmall) {
    WakatimeStats()
} timeline: {
    WakaTimeEntry(date: Date(), stats: nil)
}
