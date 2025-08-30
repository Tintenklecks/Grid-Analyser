# Grid Analyzer - JSON Persistence Implementation

## Overview
The app now stores all fetched data in a JSON file in the documents directory, preventing automatic API calls on startup and only updating when the user explicitly pulls to refresh.

## Changes Made

### 1. New Persistence Layer

#### `PersistedCoinData.swift`
- Stores coin data with calculated analysis results (trades, grid density)
- Includes timestamp and grid spacing used for calculations
- Codable for JSON serialization

#### `PersistenceService.swift`
- Handles JSON file operations in documents directory
- Saves data to `coin_data.json`
- Provides load, save, and delete operations

### 2. Updated Repository Pattern

#### `CoinRepository.swift`
- Now saves all fetched data to JSON file
- Calculates and stores analysis results during fetch
- Returns `PersistedDataContainer` with pre-calculated values
- No more memory caching - uses file persistence

### 3. Modified ViewModel Logic

#### `CoinListViewModel.swift`
- `loadData()`: Only loads from persisted JSON file, no API calls
- `refreshData()`: Explicitly fetches new data via pull-to-refresh
- Smart recalculation: Only recalculates trades if grid spacing changed
- Otherwise uses pre-calculated values from JSON

## User Experience

### On App Launch
1. App checks for `coin_data.json` in documents directory
2. If found: Displays saved data immediately (no API calls)
3. If not found: Automatically fetches data from API (first launch experience)
4. If loading JSON fails: Automatically fetches fresh data as fallback

### Pull to Refresh
1. User pulls down on the list
2. App fetches fresh data from API (~100 requests)
3. Calculates all trades and analysis
4. Saves everything to JSON file
5. Updates display

### Settings Changes
- If grid spacing changes: Recalculates trades using stored price data
- Other settings (display count, critz): Just re-filters/formats existing data
- No API calls needed for settings changes

## File Location
The JSON file is stored at:
```
~/Documents/coin_data.json
```

On simulator:
```
~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Documents/coin_data.json
```

## JSON Structure
```json
{
  "coins": [
    {
      "symbol": "BTC",
      "prices": [42000.5, 42100.0, ...],
      "minPrice": 41000.0,
      "maxPrice": 43000.0,
      "avgPrice": 42000.0,
      "changePercent": 2.5,
      "successfulTrades": 45,
      "gridDensity": 20,
      "gridSpacing": 0.1,
      "timestamp": "2024-01-20T10:30:00Z"
    },
    ...
  ],
  "lastUpdateTime": "2024-01-20T10:30:00Z",
  "gridSpacing": 0.1
}
```

## Benefits
1. **No automatic API calls**: Saves bandwidth and API quota
2. **Instant startup**: Shows cached data immediately
3. **Offline support**: Works without internet (shows last saved data)
4. **Efficient recalculation**: Only recalculates when necessary
5. **User control**: Updates only when user explicitly requests 