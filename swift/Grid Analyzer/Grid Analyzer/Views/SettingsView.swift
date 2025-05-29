//
//  SettingsView.swift
//  Grid Analyzer
//
//  Settings view for configuring app parameters
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Grid Trading Parameters") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Grid Delta: \(String(format: "%.1f", settings.gridDelta))%", systemImage: "square.grid.3x3")
                        Slider(value: $settings.gridDelta, in: 0.1...2.0, step: 0.1)
                            .tint(.blue)
                        Text("The percentage spacing between grid lines")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Display Top \(settings.displayTopCoins) Coins", systemImage: "chart.line.uptrend.xyaxis")
                        Slider(value: Binding(
                            get: { Double(settings.displayTopCoins) },
                            set: { settings.displayTopCoins = Int($0) }
                        ), in: 5...100, step: 5)
                            .tint(.blue)
                        Text("Number of coins to display in the list")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Critical Threshold: \(String(format: "%.1f", settings.critz))%", systemImage: "exclamationmark.triangle")
                        Slider(value: $settings.critz, in: 0.5...5.0, step: 0.5)
                            .tint(.blue)
                        Text("Threshold for trend indicator colors")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    Button(action: {
                        settings.reset()
                    }) {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 