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
}

final class PersistenceService: PersistenceServiceProtocol {
    private let fileName = "coin_data.json"
    private let selectionsFileName = "selected_coins.json"
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var fileURL: URL {
        documentsDirectory.appendingPathComponent(fileName)
    }
    
    private var selectionsFileURL: URL {
        documentsDirectory.appendingPathComponent(selectionsFileName)
    }
    
    func save(_ container: PersistedDataContainer) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(container)
        try data.write(to: fileURL)
        
        print("Saved coin data to: \(fileURL.path)")
    }
    
    func load() throws -> PersistedDataContainer? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("No persisted data found at: \(fileURL.path)")
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let container = try decoder.decode(PersistedDataContainer.self, from: data)
        print("Loaded coin data from: \(fileURL.path)")
        return container
    }
    
    func delete() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
            print("Deleted coin data at: \(fileURL.path)")
        }
    }
    
    func saveSelections(_ selections: Set<String>) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(selections)
        try data.write(to: selectionsFileURL)
        
        print("Saved selections to: \(selectionsFileURL.path)")
    }
    
    func loadSelections() throws -> Set<String>? {
        guard FileManager.default.fileExists(atPath: selectionsFileURL.path) else {
            print("No selections found at: \(selectionsFileURL.path)")
            return nil
        }
        
        let data = try Data(contentsOf: selectionsFileURL)
        let selections = try JSONDecoder().decode(Set<String>.self, from: data)
        print("Loaded selections from: \(selectionsFileURL.path)")
        return selections
    }
} 