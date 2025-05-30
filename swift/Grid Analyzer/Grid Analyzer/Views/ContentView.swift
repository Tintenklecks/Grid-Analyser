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
        ZStack {
            CoinListView(settings: settings)
            
            // Floating settings button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.accentColor))
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings)
        }
    }
}

#Preview {
    ContentView()
} 
