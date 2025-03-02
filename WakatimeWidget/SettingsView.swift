//
//  SettingsView.swift
//  WakatimeWidget
//
//  Created by Liam Willey on 1/29/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var wakaTimeService = WakaTimeService.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("API Key", text: $wakaTimeService.apiKey)
                        .onChange(of: wakaTimeService.apiKey) {
                            wakaTimeService.updateApiKey()
                        }
                } header: {
                    Text("API Key")
                } footer: {
                    Text("Enter your WakaTime/HakaTime API key.")
                }
                // TODO: add date selection
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
