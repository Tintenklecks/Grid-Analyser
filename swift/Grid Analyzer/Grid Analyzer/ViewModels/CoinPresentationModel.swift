//
//  CoinPresentationModel.swift
//  Grid Analyzer
//
//  Presentation model for coin display
//

import Foundation
import SwiftUI

struct CoinPresentationModel: Identifiable, Hashable {
    let id: String
    let symbol: String
    let prices: [Double]
    let minPrice: Double
    let maxPrice: Double
    let avgPrice: Double
    let changePercent: Double
    let successfulTrades: Int
    let gridDensity: Int
    let isSelected: Bool
    let critz: Int
    
    init(from analysis: GridTradingAnalyzer.Analysis, isSelected: Bool, critz: Int) {
        self.id = analysis.coin.symbol
        self.symbol = analysis.coin.symbol
        self.prices = analysis.coin.prices
        self.minPrice = analysis.coin.minPrice
        self.maxPrice = analysis.coin.maxPrice
        self.avgPrice = analysis.coin.avgPrice
        self.changePercent = analysis.coin.changePercent
        self.successfulTrades = analysis.successfulTrades
        self.gridDensity = analysis.gridDensity
        self.isSelected = isSelected
        self.critz = critz
    }
    
    // MARK: - Computed Properties for Display
    
    var selectionColor: Color {
        isSelected ? .blue : Color(.systemGray4)
    }
    
    var tradesTextColor: Color {
        if successfulTrades >= critz {
            return .green
        } else if successfulTrades > 0 {
            return .orange
        } else {
            return .red
        }
    }
    
    var formattedMinPrice: String {
        formatPrice(minPrice)
    }
    
    var formattedMaxPrice: String {
        formatPrice(maxPrice)
    }
    
    var formattedAvgPrice: String {
        formatPrice(avgPrice)
    }
    
    var formattedChangePercent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.positivePrefix = "+"
        return formatter.string(from: NSNumber(value: changePercent / 100)) ?? "0%"
    }
    
    var changeArrowName: String {
        if changePercent > 0 {
            return "arrow.up.right"
        } else if changePercent < 0 {
            return "arrow.down.right"
        } else {
            return "arrow.right"
        }
    }
    
    var changeColor: Color {
        if changePercent > 0 {
            return .green
        } else if changePercent < 0 {
            return .red
        } else {
            return .primary
        }
    }
    
    // MARK: - Private Helpers
    
    private func formatPrice(_ price: Double) -> String {
        if price < 1 {
            return String(format: "%.4f", price)
        } else if price < 100 {
            return String(format: "%.2f", price)
        } else {
            return String(format: "%.0f", price)
        }
    }
} 