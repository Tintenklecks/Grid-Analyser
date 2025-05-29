//
//  GridTradingAnalyzer.swift
//  Grid Analyzer
//
//  Business model for grid trading analysis
//

import Foundation

struct GridTradingAnalyzer {
    
    struct Analysis {
        let coin: Coin
        let successfulTrades: Int
        let gridDensity: Int
    }
    
    private let gridSpacing: Double
    
    init(gridSpacing: Double) {
        self.gridSpacing = gridSpacing
    }
    
    func analyze(_ coin: Coin) -> Analysis {
        let trades = simulateGridTrading(for: coin)
        let density = calculateGridDensity(for: coin)
        
        return Analysis(
            coin: coin,
            successfulTrades: trades,
            gridDensity: density
        )
    }
    
    private func simulateGridTrading(for coin: Coin) -> Int {
        let gridSpacingDecimal = gridSpacing / 100.0
        let numLines = Int(floor((coin.maxPrice - coin.minPrice) / (coin.minPrice * gridSpacingDecimal)))
        let gridLines = (0...numLines).map { coin.minPrice * (1 + gridSpacingDecimal * Double($0)) }
        
        var trades = 0
        var activeOrders: [Double: Double] = [:]
        
        for price in coin.prices {
            // Check for buy orders
            for i in (0..<gridLines.count-1).reversed() {
                let buyLine = gridLines[i]
                let sellLine = buyLine * (1 + gridSpacingDecimal)
                
                if price < buyLine && !activeOrders.keys.contains(buyLine) {
                    activeOrders[buyLine] = sellLine
                    break
                }
            }
            
            // Check for sell orders
            let hitSellLines = activeOrders.filter { price > $0.value }.keys
            for buyLine in hitSellLines {
                trades += 1
                activeOrders.removeValue(forKey: buyLine)
            }
        }
        
        return trades
    }
    
    private func calculateGridDensity(for coin: Coin) -> Int {
        let gridSpacingDecimal = gridSpacing / 100.0
        return Int(floor((coin.maxPrice - coin.minPrice) / (coin.minPrice * gridSpacingDecimal))) + 1
    }
} 