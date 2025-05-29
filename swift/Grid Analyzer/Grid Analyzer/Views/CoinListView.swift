//
//  CoinListView.swift
//  Grid Analyzer
//
//  Main view for displaying the list of coins
//

import SwiftUI

struct CoinListView: View {
    @StateObject private var viewModel: CoinListViewModel
    @ObservedObject private var settings: Settings
    @State private var showingSettings = false
    
    init(settings: Settings) {
        self.settings = settings
        self._viewModel = StateObject(wrappedValue: CoinListViewModel(settings: settings))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.coins.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    coinListContent
                }
                
                if viewModel.isProcessing {
                    progressOverlay
                }
            }
            .navigationTitle("Grid Trading Analyzer")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let lastUpdate = viewModel.lastUpdateTime {
                        Text(timeAgoString(from: lastUpdate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
    
    private var coinListContent: some View {
        ScrollView {
            // Selected coins header
            if !viewModel.selectedSymbols.isEmpty {
                selectedCoinsHeader
            }
            
            // Coin list
            LazyVStack(spacing: 8) {
                ForEach(viewModel.coins) { coin in
                    CoinRowView(coin: coin) {
                        viewModel.toggleSelection(for: coin.symbol)
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
    
    private var selectedCoinsHeader: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(viewModel.selectedSymbols.sorted()), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Data Available")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Pull down to load data")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var progressOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 16) {
                    Text(viewModel.progressTitle)
                        .font(.headline)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    
                    Text(viewModel.progressDetail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 10)
                )
            }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
} 