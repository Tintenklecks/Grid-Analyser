//
//  CoinListView.swift
//  Grid Analyzer
//
//  View for displaying the list of coins
//

import SwiftUI

struct CoinListView: View {
    @StateObject private var viewModel: CoinListViewModel
    @State private var selectedCoin: CoinPresentationModel?
    
    init(settings: Settings) {
        _viewModel = StateObject(wrappedValue: CoinListViewModel(settings: settings))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.coins.isEmpty {
                    loadingView
                } else {
                    coinList
                }
            }
            .navigationTitle("Grid Analyzer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let lastUpdate = viewModel.lastUpdateTime {
                        Text("Updated: \(lastUpdate, formatter: timeFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(coin: coin)
            }
        }
        .task {
            await viewModel.loadData()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .overlay {
            if viewModel.isProcessing {
                ProcessingOverlay(
                    title: viewModel.progressTitle,
                    detail: viewModel.progressDetail
                )
            }
        }
    }
    
    private var coinList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(viewModel.coins) { coin in
                    CoinRowView(
                        coin: coin,
                        onToggleSelection: {
                            viewModel.toggleSelection(for: coin.symbol)
                        },
                        onTapDetail: {
                            selectedCoin = coin
                        }
                    )
                    .background(Color(UIColor.systemBackground))
                    
                    Divider()
                }
            }
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading coin data...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }
}

struct ProcessingOverlay: View {
    let title: String
    let detail: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if !detail.isEmpty {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(30)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
        }
    }
} 