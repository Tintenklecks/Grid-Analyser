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
            VStack(spacing: 20) {
                // Header
                headerSection
                    .padding(.horizontal)
                
                // Time Range Selector
                timeRangeSelector
                    .padding(.horizontal)
                
                // Price Chart
                chartSection
                    .padding(.horizontal)
                
                // Statistics
                statisticsSection
                    .padding(.horizontal)
                
                // Tendencies
                tendenciesSection
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(coin.symbol)
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Price and change
            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(coin.formattedAvgPrice)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                    Text("USDT")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: coin.changeArrowName)
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(coin.formattedChangePercent)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(coin.changeColor)
            }
            
            // Selection status
            if coin.isSelected {
                Label("Selected for monitoring".localized, systemImage: "checkmark.circle.fill")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.tint)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Chart".localized)
                .font(.headline)
            
            Chart {
                ForEach(chartData) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.index),
                        y: .value("Price", dataPoint.price)
                    )
                    .foregroundStyle(coin.changeColor.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                }
                
                if let lastPoint = chartData.last {
                    PointMark(
                        x: .value("Time", lastPoint.index),
                        y: .value("Price", lastPoint.price)
                    )
                    .foregroundStyle(coin.changeColor)
                    .symbolSize(100)
                }
            }
            .frame(height: 240)
            .chartYScale(domain: chartYDomain)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                        .foregroundStyle(Color(.systemGray5))
                    AxisValueLabel {
                        if let index = value.as(Int.self) {
                            Text(timeLabel(for: index))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(Color(.systemGray5))
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Statistics".localized)
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Price statistics
                HStack(spacing: 12) {
                    StatCard(
                        title: "MIN".localized,
                        value: coin.formattedMinPrice,
                        icon: "arrow.down.circle.fill",
                        color: .red
                    )
                    
                    StatCard(
                        title: "AVG".localized, 
                        value: coin.formattedAvgPrice,
                        icon: "minus.circle.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "MAX".localized,
                        value: coin.formattedMaxPrice,
                        icon: "arrow.up.circle.fill",
                        color: .green
                    )
                }
                
                // Trading statistics
                HStack(spacing: 12) {
                    StatCard(
                        title: "TRADES".localized,
                        value: "\(coin.successfulTrades)",
                        icon: "chart.line.uptrend.xyaxis.circle.fill",
                        color: coin.tradesTextColor
                    )
                    
                    StatCard(
                        title: "GRID DENSITY".localized,
                        value: "\(coin.gridDensity)",
                        icon: "square.grid.3x3.fill",
                        color: .blue
                    )
                }
            }
        }
    }
    
    private var tendenciesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Tendencies".localized)
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 0) {
                ForEach(Array(TimeRange.allCases.enumerated()), id: \.element) { index, range in
                    TendencyRow(
                        timeRange: range.rawValue,
                        tendency: calculateTendency(for: range),
                        change: calculateChange(for: range)
                    )
                    
                    if index < TimeRange.allCases.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Helper Views
    
    private struct StatCard: View {
        let title: String
        let value: String
        let icon: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .symbolRenderingMode(.hierarchical)
                
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                return .secondary
            }
        }
        
        var tendencyIcon: String {
            if tendency > 0 {
                return "arrow.up.right.circle.fill"
            } else if tendency < 0 {
                return "arrow.down.right.circle.fill"
            } else {
                return "arrow.right.circle.fill"
            }
        }
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: tendencyIcon)
                    .font(.title3)
                    .foregroundStyle(tendencyColor)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 28)
                
                Text(timeRange)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(width: 50, alignment: .leading)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ProgressView(value: abs(tendency), total: 10)
                        .progressViewStyle(.linear)
                        .tint(tendencyColor)
                        .frame(width: 80)
                    
                    Text(change)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(tendencyColor)
                        .frame(width: 60, alignment: .trailing)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
