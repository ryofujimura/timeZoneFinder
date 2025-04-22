//
//  DataModel.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import Foundation
import SwiftUI

// Add Identifiable conformance for ForEach and Codable for saving/loading
struct UserCity: Codable, Identifiable {
    var id: String // City name used as ID
    var info: CityInfo
}

struct CityInfo: Codable {
    var timeDifference: Int
    var emoji: String
}

class DataModel: ObservableObject {
    @Published var timeFormat: String = "12hr" {
        didSet {
            // Saves the time format to UserDefaults when changed
            UserDefaults.standard.set(timeFormat, forKey: "timeFormat")
        }
    }
    // Replace the dictionary with an array of UserCity
    @Published var userCities: [UserCity] = [] {
        didSet {
            // Saves the user cities data to UserDefaults when it is updated
            saveUserCities()
        }
    }

    init() {
        // Loads user cities and time format from UserDefaults during initialization
        loadUserCities() // Renamed function
        loadTimeFormat()
    }

    // Renamed function to save the array
    func saveUserCities() {
        // Encodes and saves userCities to UserDefaults
        if let encoded = try? JSONEncoder().encode(userCities) {
            UserDefaults.standard.set(encoded, forKey: "userCities") // Use new key
        }
    }

    // Renamed function to load the array
    func loadUserCities() {
        // Try loading the new array format first
        if let savedData = UserDefaults.standard.data(forKey: "userCities"), // Use new key
           let decodedData = try? JSONDecoder().decode([UserCity].self, from: savedData) {
            userCities = decodedData
            return // Successfully loaded new format, exit
        }

        // If new format not found, try migrating from the old dictionary format
        if let oldSavedData = UserDefaults.standard.data(forKey: "cityData"), // Check old key
           let decodedOldData = try? JSONDecoder().decode([String: CityInfo].self, from: oldSavedData) {
            // Convert dictionary to array - maintaining dictionary order isn't guaranteed,
            // but it's the best we can do for migration. New items will be ordered.
            userCities = decodedOldData.map { UserCity(id: $0.key, info: $0.value) }
                                      // Consider sorting alphabetically for a consistent initial migration order
                                      .sorted { $0.id < $1.id }

            saveUserCities() // Save the migrated data in the new format
            UserDefaults.standard.removeObject(forKey: "cityData") // Remove the old data
            print("Migrated old cityData format to new userCities format.")
        }
    }

    func loadTimeFormat() {
        // Loads the time format setting from UserDefaults, defaulting to "12hr" if not found
        timeFormat = UserDefaults.standard.string(forKey: "timeFormat") ?? "12hr"
    }
}

//Global colors
extension Color {
    static let offblack = Color(red: 16/256, green: 16/256, blue: 16/256)
    static let darkGray = Color(red: 132/256, green: 132/256, blue: 132/256)
    static let lightGray = Color(red: 245/256, green: 245/256, blue: 245/256)
    static let offwhite = Color(red: 255/256, green: 255/256, blue: 255/256)
}
