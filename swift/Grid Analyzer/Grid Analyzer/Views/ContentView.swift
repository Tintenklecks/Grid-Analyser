//
//  ContentView.swift
//  Grid Analyzer
//
//  Root content view of the application
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = Settings()
    
    var body: some View {
        CoinListView(settings: settings)
    }
}

#Preview {
    ContentView()
} 
