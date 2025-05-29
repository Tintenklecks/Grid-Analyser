//
//  CoinRowView.swift
//  Grid Analyzer
//
//  View for displaying a single coin row
//

import SwiftUI

struct CoinRowView: View {
    let coin: CoinPresentationModel
    let onToggleSelection: () -> Void
    let onTapDetail: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side - Selection area
            Button(action: onToggleSelection) {
                HStack(spacing: 12) {
                    // Selection indicator
                    Circle()
                        .fill(coin.selectionColor)
                        .frame(width: 10, height: 10)
                    
                    // Symbol
                    Text(coin.symbol)
                        .font(.headline)
                        .frame(width: 60, alignment: .leading)
                }
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Right side - Detail area
            Button(action: onTapDetail) {
                HStack {
                    // Trades with color coding
                    Text("\(coin.successfulTrades)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(coin.tradesTextColor)
                        .frame(width: 50, alignment: .trailing)
                    
                    // Min/Max spread
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(coin.formattedMinPrice)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(coin.formattedMaxPrice)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 90, alignment: .trailing)
                    
                    // Change percentage with arrow
                    HStack(spacing: 4) {
                        Image(systemName: coin.changeArrowName)
                            .font(.caption)
                        Text(coin.formattedChangePercent)
                            .font(.caption)
                    }
                    .foregroundColor(coin.changeColor)
                    .frame(width: 70, alignment: .trailing)
                    
                    // Navigation chevron
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 16)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
    }
} 