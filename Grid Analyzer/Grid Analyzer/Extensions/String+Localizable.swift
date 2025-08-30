//
//  String+Localizable.swift
//  Grid Analyzer
//
//  Extension for localization support
//

import Foundation

extension String {
    /// Returns a localized version of the string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized string with formatting
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
} 