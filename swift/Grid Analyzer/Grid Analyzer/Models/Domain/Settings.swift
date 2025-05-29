//
//  Settings.swift
//  Grid Analyzer
//
//  Model for managing application settings
//

import Foundation

final class Settings: ObservableObject {
    @Published var gridDelta: Double {
        didSet {
            UserDefaults.standard.set(gridDelta, forKey: Keys.gridDelta)
        }
    }
    
    @Published var displayTopCoins: Int {
        didSet {
            UserDefaults.standard.set(displayTopCoins, forKey: Keys.displayTopCoins)
        }
    }
    
    @Published var critz: Double {
        didSet {
            UserDefaults.standard.set(critz, forKey: Keys.critz)
        }
    }
    
    private enum Keys {
        static let gridDelta = "settings.gridDelta"
        static let displayTopCoins = "settings.displayTopCoins"
        static let critz = "settings.critz"
    }
    
    init() {
        let storedGridDelta = UserDefaults.standard.double(forKey: Keys.gridDelta)
        self.gridDelta = storedGridDelta == 0 ? 0.1 : storedGridDelta
        
        let storedDisplayTopCoins = UserDefaults.standard.integer(forKey: Keys.displayTopCoins)
        self.displayTopCoins = storedDisplayTopCoins == 0 ? 20 : storedDisplayTopCoins
        
        let storedCritz = UserDefaults.standard.double(forKey: Keys.critz)
        self.critz = storedCritz == 0 ? 2.0 : storedCritz
    }
    
    func reset() {
        gridDelta = 0.1
        displayTopCoins = 20
        critz = 2.0
    }
} 