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
                Section {
                    // Grid Delta
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Grid Delta")
                                    .font(.body)
                                Text("\(String(format: "%.1f", settings.gridDelta))%")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                        } icon: {
                            Image(systemName: "square.grid.3x3")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(.tint)
                                .symbolRenderingMode(.monochrome)
                                .frame(width: 36)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    Slider(value: $settings.gridDelta, in: 0.1...2.0, step: 0.1)
                    
                    Text("The percentage spacing between grid lines")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Grid Trading")
                }
                
                Section {
                    // Display Top Coins
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Display Coins")
                                    .font(.body)
                                Text("\(settings.displayTopCoins)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                        } icon: {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(.tint)
                                .symbolRenderingMode(.monochrome)
                                .frame(width: 36)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    Slider(value: Binding(
                        get: { Double(settings.displayTopCoins) },
                        set: { settings.displayTopCoins = Int($0) }
                    ), in: 5...100, step: 5)
                    
                    Text("Number of top coins to display in the list")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Display Options")
                }
                
                Section {
                    // Critical Threshold
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Critical Threshold")
                                    .font(.body)
                                Text("\(String(format: "%.1f", settings.critz))%")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(.orange)
                                .symbolRenderingMode(.monochrome)
                                .frame(width: 36)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    Slider(value: $settings.critz, in: 0.5...5.0, step: 0.5)
                    
                    Text("Threshold for trend indicator colors")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Indicators")
                }
                
                Section {
                    Button(action: {
                        settings.reset()
                    }) {
                        HStack {
                            Spacer()
                            Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .foregroundStyle(.red)
                } footer: {
                    Text("Reset all settings to their default values")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
} 