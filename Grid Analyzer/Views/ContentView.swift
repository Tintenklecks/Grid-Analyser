//
//  ContentView.swift
//  Grid Analyzer
//
//  Main content view of the app
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = Settings()
    @State private var showingSettings = false
    
    var body: some View {
        CoinListView(settings: settings)
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings)
            }
            .environment(\.showingSettings, $showingSettings)
    }
}

// Environment key for settings sheet
private struct ShowingSettingsKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var showingSettings: Binding<Bool> {
        get { self[ShowingSettingsKey.self] }
        set { self[ShowingSettingsKey.self] = newValue }
    }
}

#Preview {
    ContentView()
} 
