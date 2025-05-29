//
//  Coin.swift
//  Grid Analyzer
//
//  Domain model representing a cryptocurrency
//

import Foundation

struct Coin: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let prices: [Double]
    let minPrice: Double
    let maxPrice: Double
    let avgPrice: Double
    let changePercent: Double
    
    init(symbol: String, prices: [Double]) {
        self.symbol = symbol
        self.prices = prices
        self.minPrice = prices.min() ?? 0
        self.maxPrice = prices.max() ?? 0
        self.avgPrice = prices.isEmpty ? 0 : prices.reduce(0, +) / Double(prices.count)
        
        if let startPrice = prices.first,
           let endPrice = prices.last,
           startPrice > 0 {
            self.changePercent = ((endPrice - startPrice) / startPrice) * 100
        } else {
            self.changePercent = 0
        }
    }
    
    static func == (lhs: Coin, rhs: Coin) -> Bool {
        lhs.symbol == rhs.symbol
    }
} 