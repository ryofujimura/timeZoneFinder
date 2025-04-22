//
//  DataModel.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import Foundation
import SwiftUI

// Define CityEntry struct to hold city data and ensure identifiable conformance for ForEach
struct CityEntry: Codable, Identifiable {
    let id = UUID() // Use UUID for stable identity
    var name: String
    var info: CityInfo
}

class DataModel: ObservableObject {
    @Published var timeFormat: String = "12hr" {
        didSet {
            // Saves the time format to UserDefaults when changed
            UserDefaults.standard.set(timeFormat, forKey: "timeFormat")
        }
    }
    // Change cityData to an array of CityEntry to maintain order
    @Published var cityData: [CityEntry] = [] {
        didSet {
            // Saves the city data to UserDefaults when it is updated
            saveCityData()
        }
    }

    init() {
        // Loads city data and time format from UserDefaults during initialization
        loadCityData()
        loadTimeFormat()
    }

    func saveCityData() {
        // Encodes and saves the array of CityEntry
        // Use a new key "cityDataArray" to avoid conflict with old format and facilitate migration
        if let encoded = try? JSONEncoder().encode(cityData) {
            UserDefaults.standard.set(encoded, forKey: "cityDataArray")
        }
    }

    func loadCityData() {
        // Try loading the new array format first
        if let savedData = UserDefaults.standard.data(forKey: "cityDataArray"),
           let decodedData = try? JSONDecoder().decode([CityEntry].self, from: savedData) {
            cityData = decodedData
            return // Successfully loaded new format
        }

        // Fallback: Try loading the old dictionary format ("cityData") and migrate
        if let savedOldData = UserDefaults.standard.data(forKey: "cityData"), // Check old key
           let decodedOldData = try? JSONDecoder().decode([String: CityInfo].self, from: savedOldData) {
           // Convert dictionary to array - note: initial order might be arbitrary
            cityData = decodedOldData.map { CityEntry(name: $0.key, info: $0.value) }
                                      .sorted { $0.info.timeDifference < $1.info.timeDifference } // Apply some initial sort order
            saveCityData() // Save immediately in the new format (using the new key "cityDataArray")
            UserDefaults.standard.removeObject(forKey: "cityData") // Remove old data to prevent re-migration
        } else {
            // If neither new nor old data exists, initialize as empty
            cityData = []
        }
    }
    
    // Add method to move cities within the array using move(fromOffsets:toOffset:)
    func moveCity(from source: IndexSet, to destination: Int) {
        cityData.move(fromOffsets: source, toOffset: destination)
        // No need to call saveCityData() explicitly, as the @Published property observer does it.
    }

    func loadTimeFormat() {
        // Loads the time format setting from UserDefaults, defaulting to "12hr" if not found
        timeFormat = UserDefaults.standard.string(forKey: "timeFormat") ?? "12hr"
    }
}

struct CityInfo: Codable {
    var timeDifference: Int
    var emoji: String
}

//Global colors
extension Color {
    static let offblack = Color(red: 16/256, green: 16/256, blue: 16/256)
    static let darkGray = Color(red: 132/256, green: 132/256, blue: 132/256)
    static let lightGray = Color(red: 245/256, green: 245/256, blue: 245/256)
    static let offwhite = Color(red: 255/256, green: 255/256, blue: 255/256)
}
