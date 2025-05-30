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
    @State private var showingRefreshConfirmation = false
    @State private var coinToUnselect: String?
    @State private var showingUnselectConfirmation = false
    @Environment(\.showingSettings) var showingSettings
    
    init(settings: Settings) {
        _viewModel = StateObject(wrappedValue: CoinListViewModel(settings: settings))
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Selected coins section
                if !viewModel.selectedSymbols.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(viewModel.selectedSymbols).sorted(), id: \.self) { symbol in
                                    SelectedCoinChip(symbol: symbol) {
                                        coinToUnselect = symbol
                                        showingUnselectConfirmation = true
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                
                // Coins list section
                Section {
                    if viewModel.isLoading && viewModel.coins.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 16) {
                                ProgressView()
                                Text("Loading coin data...".localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 40)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    } else {
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
                        }
                    }
                } header: {
                    if let lastUpdate = viewModel.lastUpdateTime {
                        Text("Updated %@".localized(with: lastUpdate.formatted(date: .omitted, time: .shortened)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Grid Analyzer".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { showingRefreshConfirmation = true }) {
                            Image(systemName: "arrow.clockwise")
                                .fontWeight(.medium)
                        }
                        
                        Button(action: { showingSettings.wrappedValue = true }) {
                            Image(systemName: "gearshape")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(coin: coin)
            }
            .refreshable {
                showingRefreshConfirmation = true
            }
        }
        .task {
            await viewModel.loadData()
        }
        .alert("Error".localized, isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK".localized) {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .alert("Refresh Data?".localized, isPresented: $showingRefreshConfirmation) {
            Button("Cancel".localized, role: .cancel) { }
            Button("Refresh".localized) {
                Task {
                    await viewModel.refreshData()
                }
            }
        } message: {
            Text("This will fetch fresh data from Binance API.\n\nThis process may take up to 1 minute to complete.".localized)
        }
        .alert("Unselect Coin?".localized, isPresented: $showingUnselectConfirmation) {
            Button("Cancel".localized, role: .cancel) { }
            Button("Unselect".localized, role: .destructive) {
                if let symbol = coinToUnselect {
                    viewModel.toggleSelection(for: symbol)
                }
            }
        } message: {
            if let symbol = coinToUnselect {
                Text("Do you want to unselect %@?".localized(with: symbol))
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
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }
}

struct SelectedCoinChip: View {
    let symbol: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(symbol)
                    .font(.footnote)
                    .fontWeight(.medium)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .symbolRenderingMode(.hierarchical)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.tint)
            .clipShape(Capsule())
        }
    }
}

struct ProcessingOverlay: View {
    let title: String
    let detail: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    if !detail.isEmpty {
                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(32)
            .background(.ultraThinMaterial.opacity(0.9), in: RoundedRectangle(cornerRadius: 16))
            .transition(.scale.combined(with: .opacity))
        }
    }
} 