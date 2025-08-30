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
        HStack(spacing: 16) {
            // Selection button
            Button(action: onToggleSelection) {
                Image(systemName: coin.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(coin.isSelected ? Color.accentColor : .secondary)
                    .symbolRenderingMode(.monochrome)
            }
            .buttonStyle(.plain)
            
            // Coin info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(coin.symbol)
                        .font(.headline)
                    
                    Spacer()
                    
                    // Change indicator
                    HStack(spacing: 4) {
                        Image(systemName: coin.changeArrowName)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(coin.formattedChangePercent)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(coin.changeColor)
                }
                
                HStack {
                    // Trades count
                    Label {
                        Text("\(coin.successfulTrades)")
                            .font(.caption)
                    } icon: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Price range
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Text("Min".localized)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text(coin.formattedMinPrice)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Text("Max".localized)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text(coin.formattedMaxPrice)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onTapGesture {
                onTapDetail()
            }
            
            // Navigation chevron
            Button(action: onTapDetail) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .listRowBackground(
            coin.isSelected ? Color.accentColor.opacity(0.08) : Color.clear
        )
    }
} 
