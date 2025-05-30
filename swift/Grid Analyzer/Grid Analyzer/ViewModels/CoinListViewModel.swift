//
//  CoinListViewModel.swift
//  Grid Analyzer
//
//  View model for the coin list view
//

import Foundation
import Combine

@MainActor
final class CoinListViewModel: ObservableObject {
    // Published properties for view binding
    @Published private(set) var coins: [CoinPresentationModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isProcessing = false
    @Published private(set) var progressTitle = ""
    @Published private(set) var progressDetail = ""
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdateTime: Date?
    @Published private(set) var selectedSymbols: Set<String> = []
    
    // Dependencies
    private let repository: CoinRepositoryProtocol
    private let settings: Settings
    private var availableSymbols: [String] = []
    
    // Private state
    private var currentContainer: PersistedDataContainer?
    private var refreshTask: Task<Void, Never>?
    
    init(repository: CoinRepositoryProtocol = CoinRepository(), settings: Settings) {
        self.repository = repository
        self.settings = settings
        self.lastUpdateTime = repository.lastUpdateTime
        self.selectedSymbols = repository.loadSelections()
        self.availableSymbols = repository.loadAvailableCoins()
        
        print("Loaded \(availableSymbols.count) available symbols from coins.json")
        
        // Observe settings changes
        settings.objectWillChange.sink { [weak self] _ in
            self?.updatePresentationModels()
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    func loadData() async {
        // Try to load persisted data first
        do {
            if let container = try repository.loadPersistedData() {
                currentContainer = container
                lastUpdateTime = container.lastUpdateTime
                selectedSymbols = repository.loadSelections()
                updatePresentationModels()
            } else {
                // No persisted data, fetch automatically
                await performDataFetch()
            }
        } catch {
            print("Failed to load persisted data: \(error)")
            // If loading fails, try to fetch fresh data
            await performDataFetch()
        }
    }
    
    func refreshData() async {
        // Cancel any existing refresh task
        refreshTask?.cancel()
        
        // Create a detached task that won't be cancelled by the refreshable modifier
        refreshTask = Task.detached { [weak self] in
            await self?.performDataFetch()
        }
        
        // Wait for the task to complete
        await refreshTask?.value
    }
    
    func toggleSelection(for symbol: String) {
        if selectedSymbols.contains(symbol) {
            selectedSymbols.remove(symbol)
        } else {
            selectedSymbols.insert(symbol)
        }
        updatePresentationModels()
        
        // Save the updated selections to disk
        Task {
            do {
                try repository.saveSelections(selectedSymbols)
                print("✅ Saved selections to disk: \(selectedSymbols)")
            } catch {
                print("❌ Failed to save selections: \(error)")
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func performDataFetch() async {
        isLoading = true
        isProcessing = true
        progressTitle = "Refreshing Data"
        errorMessage = nil
        
        // Clear any existing error
        clearError()
        
        do {
            let symbolsToLoad = Array(availableSymbols.prefix(settings.displayTopCoins))
            print("🔄 Attempting to fetch \(symbolsToLoad.count) symbols: \(symbolsToLoad)")
            print("📊 Settings - Grid Delta: \(settings.gridDelta), Display Top: \(settings.displayTopCoins)")
            
            let container = try await repository.fetchAndSaveData(
                symbols: symbolsToLoad,
                gridSpacing: settings.gridDelta,
                progress: { [weak self] title, detail in
                    self?.progressDetail = "\(title) \(detail)"
                }
            )
            
            currentContainer = container
            lastUpdateTime = container.lastUpdateTime
            updatePresentationModels()
            
        } catch let error as RepositoryError {
            switch error {
            case .noData(let message):
                errorMessage = message
            case .partialFailure(let container, let message):
                currentContainer = container
                lastUpdateTime = container.lastUpdateTime
                errorMessage = message
                updatePresentationModels()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        isProcessing = false
        progressTitle = ""
        progressDetail = ""
    }
    
    private func updatePresentationModels() {
        guard let container = currentContainer else {
            coins = []
            return
        }
        
        isProcessing = true
        progressTitle = "Processing Data"
        progressDetail = "Preparing display..."
        
        // If grid spacing changed, we need to recalculate
        let needsRecalculation = abs(container.gridSpacing - settings.gridDelta) > 0.01
        
        if needsRecalculation {
            // Need to recalculate with new grid spacing
            let analyzer = GridTradingAnalyzer(gridSpacing: settings.gridDelta)
            
            let presentationModels = container.coins
                .prefix(settings.displayTopCoins)
                .map { persistedCoin -> CoinPresentationModel in
                    let coin = persistedCoin.toCoin()
                    let analysis = analyzer.analyze(coin)
                    let isSelected = selectedSymbols.contains(coin.symbol)
                    return CoinPresentationModel(from: analysis, isSelected: isSelected, critz: Int(settings.critz))
                }
                .sorted { $0.successfulTrades > $1.successfulTrades }
            
            coins = presentationModels
        } else {
            // Use pre-calculated values from persisted data
            let presentationModels = container.coins
                .prefix(settings.displayTopCoins)
                .map { persistedCoin -> CoinPresentationModel in
                    let coin = persistedCoin.toCoin()
                    let analysis = GridTradingAnalyzer.Analysis(
                        coin: coin,
                        successfulTrades: persistedCoin.successfulTrades,
                        gridDensity: persistedCoin.gridDensity
                    )
                    let isSelected = selectedSymbols.contains(coin.symbol)
                    return CoinPresentationModel(from: analysis, isSelected: isSelected, critz: Int(settings.critz))
                }
                .sorted { $0.successfulTrades > $1.successfulTrades }
            
            coins = presentationModels
        }
        
        isProcessing = false
        progressTitle = ""
        progressDetail = ""
    }
}

// Needed import for Combine 