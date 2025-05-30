//
//  CoinDetailView.swift
//  Grid Analyzer
//
//  Detail view for displaying coin information with chart and tendencies
//

import SwiftUI
import Charts

struct CoinDetailView: View {
    let coin: CoinPresentationModel
    @State private var selectedTimeRange: TimeRange = .day
    @Environment(\.dismiss) private var dismiss
    
    enum TimeRange: String, CaseIterable {
        case day = "24h"
        case twelveHours = "12h"
        case sixHours = "6h"
        case threeHours = "3h"
        case oneHour = "1h"
        case fifteenMinutes = "15m"
        
        func dataPoints(for totalCount: Int) -> Int {
            switch self {
            case .day: return totalCount
            case .twelveHours: return totalCount / 2
            case .sixHours: return totalCount / 4
            case .threeHours: return totalCount / 8
            case .oneHour: return totalCount / 24
            case .fifteenMinutes: return max(1, totalCount / 96)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Price Chart
                chartSection
                
                // Time Range Selector
                timeRangeSelector
                
                // Statistics
                statisticsSection
                
                // Tendencies
                tendenciesSection
            }
            .padding()
        }
        .navigationTitle("Coin Details")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                if coin.isSelected {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 20, height: 20)
                } else {
                    Circle()
                        .stroke(Color(.systemGray3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
                
                Text(coin.symbol)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(coin.formattedChangePercent)
                    .font(.title2)
                    .foregroundColor(coin.changeColor)
            }
            
            HStack {
                Text("Current: ")
                    .foregroundColor(.secondary)
                Text(coin.formattedAvgPrice)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("USDT")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price Chart")
                .font(.headline)
            
            Chart {
                ForEach(chartData) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.index),
                        y: .value("Price", dataPoint.price)
                    )
                    .foregroundStyle(coin.changeColor)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: chartYDomain)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let index = value.as(Int.self) {
                            Text(timeLabel(for: index))
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatisticView(title: "Min", value: coin.formattedMinPrice, color: .red)
                StatisticView(title: "Avg", value: coin.formattedAvgPrice, color: .orange)
                StatisticView(title: "Max", value: coin.formattedMaxPrice, color: .green)
            }
            
            HStack(spacing: 20) {
                StatisticView(title: "Trades", value: "\(coin.successfulTrades)", color: coin.tradesTextColor)
                StatisticView(title: "Grid", value: "\(coin.gridDensity)", color: .blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var tendenciesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tendencies")
                .font(.headline)
            
            ForEach(TimeRange.allCases, id: \.self) { range in
                TendencyRow(
                    timeRange: range.rawValue,
                    tendency: calculateTendency(for: range),
                    change: calculateChange(for: range)
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Views
    
    private struct StatisticView: View {
        let title: String
        let value: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private struct TendencyRow: View {
        let timeRange: String
        let tendency: Double
        let change: String
        
        var tendencyColor: Color {
            if tendency > 0 {
                return .green
            } else if tendency < 0 {
                return .red
            } else {
                return .primary
            }
        }
        
        var body: some View {
            HStack {
                Text(timeRange)
                    .font(.subheadline)
                    .frame(width: 50, alignment: .leading)
                
                HStack(spacing: 4) {
                    Image(systemName: tendency > 0 ? "arrow.up.right" : tendency < 0 ? "arrow.down.right" : "arrow.right")
                        .font(.caption)
                    Text(change)
                        .font(.caption)
                }
                .foregroundColor(tendencyColor)
                
                Spacer()
                
                ProgressView(value: abs(tendency), total: 10)
                    .progressViewStyle(LinearProgressViewStyle(tint: tendencyColor))
                    .frame(width: 100)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Helper Properties and Methods
    
    private var chartData: [ChartDataPoint] {
        let startIndex = max(0, coin.prices.count - selectedTimeRange.dataPoints(for: coin.prices.count))
        let selectedPrices = Array(coin.prices[startIndex...])
        
        return selectedPrices.enumerated().map { index, price in
            ChartDataPoint(index: index, price: price)
        }
    }
    
    private var chartYDomain: ClosedRange<Double> {
        let prices = chartData.map { $0.price }
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 1
        let padding = (maxPrice - minPrice) * 0.1
        return (minPrice - padding)...(maxPrice + padding)
    }
    
    private func timeLabel(for index: Int) -> String {
        switch selectedTimeRange {
        case .day:
            return "\(index * 24 / chartData.count)h"
        case .twelveHours:
            return "\(index * 12 / chartData.count)h"
        case .sixHours:
            return "\(index * 6 / chartData.count)h"
        case .threeHours:
            return "\(index * 3 / chartData.count)h"
        case .oneHour:
            return "\(index * 60 / chartData.count)m"
        case .fifteenMinutes:
            return "\(index * 15 / chartData.count)m"
        }
    }
    
    private func calculateTendency(for range: TimeRange) -> Double {
        let startIndex = max(0, coin.prices.count - range.dataPoints(for: coin.prices.count))
        guard startIndex < coin.prices.count - 1 else { return 0 }
        
        let selectedPrices = Array(coin.prices[startIndex...])
        guard let first = selectedPrices.first, let last = selectedPrices.last else { return 0 }
        
        let change = ((last - first) / first) * 100
        return min(max(change, -10), 10) // Clamp between -10 and 10 for visualization
    }
    
    private func calculateChange(for range: TimeRange) -> String {
        let startIndex = max(0, coin.prices.count - range.dataPoints(for: coin.prices.count))
        guard startIndex < coin.prices.count - 1 else { return "0.0%" }
        
        let selectedPrices = Array(coin.prices[startIndex...])
        guard let first = selectedPrices.first, let last = selectedPrices.last else { return "0.0%" }
        
        let change = ((last - first) / first) * 100
        return String(format: "%+.2f%%", change)
    }
}

private struct ChartDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let price: Double
} 
