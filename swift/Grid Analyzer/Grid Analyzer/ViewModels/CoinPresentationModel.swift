//
//  CoinPresentationModel.swift
//  Grid Analyzer
//
//  Presentation model for formatting coin data for views
//

import Foundation

struct CoinPresentationModel: Identifiable {
    let id: UUID
    let symbol: String
    let successfulTrades: Int
    let gridDensity: Int
    let minPriceFormatted: String
    let maxPriceFormatted: String
    let avgPriceFormatted: String
    let changePercentFormatted: String
    let trendBall: String
    let trendArrow: (String, String)
    let isSelected: Bool
    
    init(from analysis: GridTradingAnalyzer.Analysis, isSelected: Bool, critz: Double) {
        self.id = analysis.coin.id
        self.symbol = analysis.coin.symbol
        self.successfulTrades = analysis.successfulTrades
        self.gridDensity = analysis.gridDensity
        self.isSelected = isSelected
        
        // Format prices
        self.minPriceFormatted = String(format: "%.2f", analysis.coin.minPrice)
        self.maxPriceFormatted = String(format: "%.2f", analysis.coin.maxPrice)
        self.avgPriceFormatted = String(format: "%.2f", analysis.coin.avgPrice)
        
        let changePercent = analysis.coin.changePercent
        
        // Format change percentage
        if changePercent >= 0 {
            self.changePercentFormatted = "+\(String(format: "%.1f", changePercent))%"
        } else {
            self.changePercentFormatted = "\(String(format: "%.1f", changePercent))%"
        }
        
        // Determine trend ball
        if changePercent > critz {
            self.trendBall = "🟢"
        } else if changePercent > -critz/2 {
            self.trendBall = "⚪"
        } else {
            self.trendBall = "🔴"
        }
        
        // Determine trend arrow
        if changePercent > critz {
            self.trendArrow = (changePercentFormatted, "arrow.up")
        } else if changePercent > critz/2 {
            self.trendArrow = (changePercentFormatted, "arrow.up.right")
        } else if changePercent > -critz/2 {
            self.trendArrow = (changePercentFormatted, "arrow.right")
        } else if changePercent > -critz {
            self.trendArrow = (changePercentFormatted, "arrow.down.right")
        } else {
            self.trendArrow = (changePercentFormatted, "arrow.down")
        }
    }
} 