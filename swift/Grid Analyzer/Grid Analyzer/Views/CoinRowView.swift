//
//  CoinRowView.swift
//  Grid Analyzer
//
//  Row view for displaying coin information
//

import SwiftUI

struct CoinRowView: View {
    let coin: CoinPresentationModel
    let onTap: () -> Void
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Button(action: onTap) {
            content
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var content: some View {
        HStack(spacing: 12) {
            // Trend indicator
            Text(coin.trendBall)
                .font(.title2)
            
            // Symbol
            Text(coin.symbol)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 60, alignment: .leading)
            
            // Trend arrow
            HStack(spacing: 4) {
                Text(coin.trendArrow.0)
                    .font(.system(.caption, design: .monospaced))
                Image(systemName: coin.trendArrow.1)
                    .font(.caption)
            }
            .foregroundColor(trendColor)
            
            Spacer()
            
            // Stats
            if horizontalSizeClass == .regular {
                // iPad/Mac layout - show more info horizontally
                HStack(spacing: 16) {
                    statItem(title: "Trades", value: "\(coin.successfulTrades)")
                    statItem(title: "Grid", value: "\(coin.gridDensity)")
                    statItem(title: "Min", value: coin.minPriceFormatted)
                    statItem(title: "Max", value: coin.maxPriceFormatted)
                    statItem(title: "Avg", value: coin.avgPriceFormatted)
                }
            } else {
                // iPhone layout - compact view
                VStack(alignment: .trailing, spacing: 2) {
                    HStack {
                        Text("Trades:")
                            .foregroundColor(.secondary)
                        Text("\(coin.successfulTrades)")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("Grid:")
                            .foregroundColor(.secondary)
                        Text("\(coin.gridDensity)")
                    }
                    .font(.caption2)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(coin.isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(coin.isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    private var trendColor: Color {
        if coin.trendArrow.1.contains("up") && !coin.trendArrow.1.contains("down") {
            return .green
        } else if coin.trendArrow.1.contains("down") {
            return .red
        } else {
            return .primary
        }
    }
} 