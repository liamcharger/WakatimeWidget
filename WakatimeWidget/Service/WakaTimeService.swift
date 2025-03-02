//
//  WakaTimeService.swift
//  WakatimeWidget
//
//  Created by Liam Willey on 1/28/25.
//

import Foundation
import WidgetKit

class WakaTimeService: ObservableObject {
    static let shared = WakaTimeService()
    
    @Published var stats: WakaTimeStats?
    @Published var apiKey = ""
    
    private let userDefaults = UserDefaults(suiteName: "group.com.liamwilley.WakatimeWidget")
    private let apiKeyString = "wakaTimeApiKey"
    private let apiUrl = "https://waka.hackclub.com/api/summary?interval=today"
    
    init() {
        getApiKey()
        fetchStats()
    }
    
    func seconds(from stats: WakaTimeStats) -> Double {
        return stats.categories.reduce(0.0) { $0 + Double($1.total) }
    }
    
    func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    func getApiKey() {
        DispatchQueue.main.async {
            self.apiKey = self.userDefaults?.string(forKey: self.apiKeyString) ?? ""
        }
    }
    
    func updateApiKey() {
        DispatchQueue.main.async {
            self.userDefaults?.set(self.apiKey, forKey: self.apiKeyString)
            self.fetchStats()
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func fetchHours(completion: @escaping (WakaTimeStats?) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
        
        print("Fetching stats from: \(url)")
        print(request.allHTTPHeaderFields)
        
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
            
            print("App response: \(String(data: data, encoding: .utf8) ?? "No data")")
            
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
    
    func fetchStats() {
        // TODO: fetch data for more days
        fetchHours { stats in
            DispatchQueue.main.async {
                self.stats = stats
            }
        }
    }
}
