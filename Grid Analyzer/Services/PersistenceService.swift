//
//  PersistenceService.swift
//  Grid Analyzer
//
//  Service for persisting coin data to documents directory
//

import Foundation

protocol PersistenceServiceProtocol {
    func save(_ container: PersistedDataContainer) throws
    func load() throws -> PersistedDataContainer?
    func delete() throws
    func saveSelections(_ selections: Set<String>) throws
    func loadSelections() throws -> Set<String>?
    func loadAvailableCoins() throws -> [String]
}

final class PersistenceService: PersistenceServiceProtocol {
    private let fileName = "coin_data.json"
    private let selectionsFileName = "selected_coins.json"
    private let coinsFileName = "coins.json"
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var fileURL: URL {
        documentsDirectory.appendingPathComponent(fileName)
    }
    
    private var selectionsFileURL: URL {
        documentsDirectory.appendingPathComponent(selectionsFileName)
    }
    
    private var coinsFileURL: URL {
        documentsDirectory.appendingPathComponent(coinsFileName)
    }
    
    init() {
        // Ensure coins.json exists in Documents folder
        ensureCoinsFileExists()
    }
    
    // MARK: - Main Data Methods
    
    func save(_ container: PersistedDataContainer) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(container)
        try data.write(to: fileURL)
        
        print("✅ Saved \(container.coins.count) coins to: \(fileURL.path)")
    }
    
    func load() throws -> PersistedDataContainer? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("ℹ️ No persisted data found at: \(fileURL.path)")
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let container = try decoder.decode(PersistedDataContainer.self, from: data)
        print("✅ Loaded \(container.coins.count) coins from: \(fileURL.path)")
        return container
    }
    
    func delete() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
            print("✅ Deleted persisted data at: \(fileURL.path)")
        }
    }
    
    // MARK: - Selections Methods
    
    func saveSelections(_ selections: Set<String>) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(Array(selections))
        try data.write(to: selectionsFileURL)
        
        print("✅ Saved \(selections.count) selections to: \(selectionsFileURL.path)")
    }
    
    func loadSelections() throws -> Set<String>? {
        guard FileManager.default.fileExists(atPath: selectionsFileURL.path) else {
            print("ℹ️ No selections found at: \(selectionsFileURL.path)")
            return nil
        }
        
        let data = try Data(contentsOf: selectionsFileURL)
        let decoder = JSONDecoder()
        
        let selectionsArray = try decoder.decode([String].self, from: data)
        print("✅ Loaded \(selectionsArray.count) selections from: \(selectionsFileURL.path)")
        return Set(selectionsArray)
    }
    
    // MARK: - Available Coins Methods
    
    private func ensureCoinsFileExists() {
        guard !FileManager.default.fileExists(atPath: coinsFileURL.path) else {
            print("✅ coins.json already exists in Documents folder")
            return
        }
        
        // Copy from bundle to Documents
        guard let bundleURL = Bundle.main.url(forResource: "coins", withExtension: "json") else {
            print("❌ coins.json not found in bundle")
            return
        }
        
        do {
            try FileManager.default.copyItem(at: bundleURL, to: coinsFileURL)
            print("✅ Copied coins.json from bundle to Documents folder")
        } catch {
            print("❌ Failed to copy coins.json: \(error)")
        }
    }
    
    func loadAvailableCoins() throws -> [String] {
        // Ensure file exists (in case it was deleted)
        ensureCoinsFileExists()
        
        guard FileManager.default.fileExists(atPath: coinsFileURL.path) else {
            throw PersistenceError.fileNotFound(fileName: coinsFileName)
        }
        
        let data = try Data(contentsOf: coinsFileURL)
        let decoder = JSONDecoder()
        
        let coins = try decoder.decode([String].self, from: data)
        print("✅ Loaded \(coins.count) available coins from: \(coinsFileURL.path)")
        return coins
    }
}

enum PersistenceError: LocalizedError {
    case fileNotFound(fileName: String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "File not found: \(fileName)"
        }
    }
} 