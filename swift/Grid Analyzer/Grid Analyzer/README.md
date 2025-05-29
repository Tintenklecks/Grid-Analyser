# Grid Analyzer - Architecture Documentation

## Overview
Grid Analyzer is a SwiftUI application for analyzing cryptocurrency grid trading opportunities. The app follows strict MVVM architecture with clear separation of concerns.

## Architecture

### MVVM + Services Pattern

```
┌─────────────────────────────────────────────────────────────┐
│                         Views                               │
│  ContentView, CoinListView, SettingsView, CoinRowView      │
└────────────────────────┬────────────────────────────────────┘
                         │ Data Binding
┌────────────────────────▼────────────────────────────────────┐
│                     ViewModels                              │
│      CoinListViewModel, CoinPresentationModel               │
└────────────────────────┬────────────────────────────────────┘
                         │ Uses
┌────────────────────────▼────────────────────────────────────┐
│                   Domain Models                             │
│             Coin, Settings, GridTradingAnalyzer             │
└────────────────────────┬────────────────────────────────────┘
                         │ Uses
┌────────────────────────▼────────────────────────────────────┐
│                     Services                                │
│         BinanceService, CoinRepository                      │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

#### Views
- **ContentView**: Root view that initializes settings
- **CoinListView**: Main list view with pull-to-refresh
- **SettingsView**: Configuration screen for all parameters
- **CoinRowView**: Individual coin row with adaptive layout

#### ViewModels
- **CoinListViewModel**: Handles presentation logic for coin list
- **CoinPresentationModel**: Formatted data for display

#### Domain Models
- **Coin**: Pure domain model for cryptocurrency data
- **Settings**: User preferences with persistence
- **GridTradingAnalyzer**: Business logic for trade analysis

#### Services
- **BinanceService**: API communication (implements CryptocurrencyDataService protocol)
- **CoinRepository**: Data loading, caching, and coordination

### Features

1. **Adaptive Layout**: Works on iPhone, iPad, and Mac
2. **Pull to Refresh**: Standard iOS/iPadOS refresh gesture
3. **Settings Management**: All configuration in dedicated view
4. **Clean Separation**: Each component has single responsibility
5. **Testable Architecture**: Business logic separated from UI

### Design Principles

- **MVVM Pattern**: Strict separation between View, ViewModel, and Model
- **Dependency Injection**: Services injected via protocols
- **Protocol-Oriented**: Key components defined by protocols
- **Reactive**: Using Combine and @Published for data flow
- **Clean Code**: Following SOLID principles 