//
//  CoinRepository.swift
//  Grid Analyzer
//
//  Repository for managing coin data loading and caching
//

import Foundation

protocol CoinRepositoryProtocol {
    func loadPersistedData() throws -> PersistedDataContainer?
    func fetchAndSaveData(symbols: [String], gridSpacing: Double, progress: @escaping (String, String) -> Void) async throws -> PersistedDataContainer
    func saveSelections(_ selections: Set<String>) throws
    func loadSelections() -> Set<String>
    func loadAvailableCoins() -> [String]
    var lastUpdateTime: Date? { get }
}

final class CoinRepository: CoinRepositoryProtocol {
    private let persistenceService: PersistenceServiceProtocol
    
    private(set) var lastUpdateTime: Date?
    
    init(persistenceService: PersistenceServiceProtocol = PersistenceService()) {
        self.persistenceService = persistenceService
        
        // Try to load last update time from persisted data
        if let container = try? persistenceService.load() {
            self.lastUpdateTime = container.lastUpdateTime
        }
    }
    
    func loadPersistedData() throws -> PersistedDataContainer? {
        return try persistenceService.load()
    }
    
    func saveSelections(_ selections: Set<String>) throws {
        try persistenceService.saveSelections(selections)
    }
    
    func loadSelections() -> Set<String> {
        return (try? persistenceService.loadSelections()) ?? []
    }
    
    func fetchAndSaveData(symbols: [String], gridSpacing: Double, progress: @escaping (String, String) -> Void) async throws -> PersistedDataContainer {
        var persistedCoins: [PersistedCoinData] = []
        var errors: [(String, String)] = []
        
        let analyzer = GridTradingAnalyzer(gridSpacing: gridSpacing)
        
        // Create a fresh BinanceService instance for this fetch operation
        let dataService = BinanceService()
        
        for (index, symbol) in symbols.enumerated() {
            await MainActor.run {
                progress("Loading \(symbol)", "(\(index + 1)/\(symbols.count))")
            }
            
            // Add a small delay to avoid rate limiting (100ms between requests)
            if index > 0 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
            }
            
            do {
                let prices = try await dataService.fetchKlines(for: symbol)
                guard !prices.isEmpty else {
                    errors.append((symbol, "No price data available"))
                    print("❌ \(symbol): No price data available")
                    continue
                }
                
                let coin = Coin(symbol: symbol, prices: prices)
                let analysis = analyzer.analyze(coin)
                let persistedCoin = PersistedCoinData(coin: coin, analysis: analysis, gridSpacing: gridSpacing)
                persistedCoins.append(persistedCoin)
                print("✅ \(symbol): Successfully fetched \(prices.count) prices")
                
            } catch let error as BinanceError {
                let errorMessage = errorDescription(for: error)
                errors.append((symbol, errorMessage))
                print("❌ \(symbol): BinanceError - \(errorMessage)")
            } catch {
                errors.append((symbol, error.localizedDescription))
                print("❌ \(symbol): Error - \(error.localizedDescription)")
            }
        }
        
        print("\n📊 Fetch Summary: Success: \(persistedCoins.count), Errors: \(errors.count)")
        
        if persistedCoins.isEmpty {
            print("❌ No coins were successfully fetched!")
            if !errors.isEmpty {
                print("Errors encountered:")
                errors.forEach { symbol, error in
                    print("  - \(symbol): \(error)")
                }
            }
            throw RepositoryError.noData(message: "Failed to fetch any coin data")
        }
        
        let container = PersistedDataContainer(coins: persistedCoins, gridSpacing: gridSpacing)
        
        // Save to file
        try persistenceService.save(container)
        
        // Update last update time
        lastUpdateTime = container.lastUpdateTime
        
        // If there were partial errors, throw them after saving
        if !errors.isEmpty {
            let errorMessages = errors.map { "\($0.0): \($0.1)" }.joined(separator: "\n")
            throw RepositoryError.partialFailure(container: container, message: "Failed to fetch data for:\n\(errorMessages)")
        }
        
        return container
    }
    
    private func errorDescription(for error: BinanceError) -> String {
        switch error {
        case .apiError(let message):
            return message
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data format"
        case .networkError(let underlyingError):
            return underlyingError.localizedDescription
        }
    }
    
    func loadAvailableCoins() -> [String] {
        do {
            return try persistenceService.loadAvailableCoins()
        } catch {
            print("Failed to load available coins: \(error)")
            // Return a default list if loading fails
            return ["BTC", "ETH", "BNB", "SOL", "XRP"]
        }
    }
}

enum RepositoryError: Error {
    case noData(message: String)
    case partialFailure(container: PersistedDataContainer, message: String)
} 