//
//  SearchHistoryViewModel.swift
//  TimezoneFinder
//
//  Created on 9/7/2024.
//

import Foundation
import SwiftUI
import Combine

class SearchHistoryViewModel: ObservableObject {
    // Published property to track search history
    @Published var searchHistory: [String] = []
    
    // Constant for maximum history items to keep
    private let maxHistoryItems = 3
    
    init() {
        // Load search history from UserDefaults
        loadSearchHistory()
    }
    
    // Add a search term to history
    func addSearchTerm(_ term: String) {
        // Don't add empty search terms
        guard !term.isEmpty else { return }
        
        DispatchQueue.main.async {
            // Remove the term if it already exists to avoid duplicates
            if let existingIndex = self.searchHistory.firstIndex(of: term) {
                self.searchHistory.remove(at: existingIndex)
            }
            
            // Add the new term at the beginning of the array
            self.searchHistory.insert(term, at: 0)
            
            // Ensure we only keep the most recent terms up to the limit
            if self.searchHistory.count > self.maxHistoryItems {
                self.searchHistory = Array(self.searchHistory.prefix(self.maxHistoryItems))
            }
            
            // Save to UserDefaults
            self.saveSearchHistory()
        }
    }
    
    // Clear all search history
    func clearSearchHistory() {
        DispatchQueue.main.async {
            self.searchHistory = []
            self.saveSearchHistory()
        }
    }
    
    // Save search history to UserDefaults
    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
    
    // Load search history from UserDefaults
    private func loadSearchHistory() {
        if let savedHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") {
            searchHistory = savedHistory
        }
    }
} 