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
}

final class PersistenceService: PersistenceServiceProtocol {
    private let fileName = "coin_data.json"
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var fileURL: URL {
        documentsDirectory.appendingPathComponent(fileName)
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
} 