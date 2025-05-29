//
//  PersistedCoinData.swift
//  Grid Analyzer
//
//  Model for persisting coin data with analysis results
//

import Foundation

struct PersistedCoinData: Codable {
    let symbol: String
    let prices: [Double]
    let minPrice: Double
    let maxPrice: Double
    let avgPrice: Double
    let changePercent: Double
    let successfulTrades: Int
    let gridDensity: Int
    let gridSpacing: Double
    let timestamp: Date
    
    init(coin: Coin, analysis: GridTradingAnalyzer.Analysis, gridSpacing: Double) {
        self.symbol = coin.symbol
        self.prices = coin.prices
        self.minPrice = coin.minPrice
        self.maxPrice = coin.maxPrice
        self.avgPrice = coin.avgPrice
        self.changePercent = coin.changePercent
        self.successfulTrades = analysis.successfulTrades
        self.gridDensity = analysis.gridDensity
        self.gridSpacing = gridSpacing
        self.timestamp = Date()
    }
    
    func toCoin() -> Coin {
        return Coin(symbol: symbol, prices: prices)
    }
}

struct PersistedDataContainer: Codable {
    let coins: [PersistedCoinData]
    let lastUpdateTime: Date
    let gridSpacing: Double
    
    init(coins: [PersistedCoinData], gridSpacing: Double) {
        self.coins = coins
        self.lastUpdateTime = Date()
        self.gridSpacing = gridSpacing
    }
} 