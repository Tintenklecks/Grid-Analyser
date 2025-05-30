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
                    if coin.isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 12, height: 12)
                    } else {
                        Circle()
                            .stroke(Color(.systemGray3), lineWidth: 1.5)
                            .frame(width: 12, height: 12)
                    }
                    
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
                    // Trades with "trades" label
                    HStack(spacing: 4) {
                        Text("\(coin.successfulTrades)")
                            .font(.caption)
                            .foregroundColor(.primary)
                        Text("trades")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 80, alignment: .trailing)
                    
                    // Min/Max with labels
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(coin.formattedMinPrice)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("min")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        HStack(spacing: 4) {
                            Text(coin.formattedMaxPrice)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("max")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 110, alignment: .trailing)
                    
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
        .background(
            coin.isSelected ? Color.accentColor.opacity(0.1) : Color(UIColor.systemBackground)
        )
    }
} 
