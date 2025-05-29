//
//  Grid_AnalyzerApp.swift
//  Grid Analyzer
//
//  Created by Ingo Böhme on 28.05.2025.
//

import SwiftUI

@main
struct Grid_AnalyzerApp: App {
    @StateObject private var settings = Settings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
