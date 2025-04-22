//
//  DataModel.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import Foundation
import SwiftUI

class DataModel: ObservableObject {
    @Published var timeFormat: String = "12hr" {
        didSet {
            // Saves the time format to UserDefaults when changed
            UserDefaults.standard.set(timeFormat, forKey: "timeFormat")
        }
    }
    @Published var cityData: [String: CityInfo] = [:] {
        didSet {
            // Saves the city data to UserDefaults when it is updated
            saveCityData()
        }
    }
    
    @Published var cityOrder: [String] = [] {
        didSet {
            // Save city order to UserDefaults when it changes
            saveCityOrder()
        }
    }

    init() {
        // Loads city data and time format from UserDefaults during initialization
        loadCityData()
        loadTimeFormat()
        loadCityOrder()
    }

    func saveCityData() {
        // Encodes and saves cityData to UserDefaults
        if let encoded = try? JSONEncoder().encode(cityData) {
            UserDefaults.standard.set(encoded, forKey: "cityData")
        }
    }

    func loadCityData() {
        // Loads and decodes city data from UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: "cityData"),
           let decodedData = try? JSONDecoder().decode([String: CityInfo].self, from: savedData) {
            cityData = decodedData
        }
    }

    func loadTimeFormat() {
        // Loads the time format setting from UserDefaults, defaulting to "12hr" if not found
        timeFormat = UserDefaults.standard.string(forKey: "timeFormat") ?? "12hr"
    }

    func saveCityOrder() {
        // Encode and save cityOrder to UserDefaults
        UserDefaults.standard.set(cityOrder, forKey: "cityOrder")
    }
    
    func loadCityOrder() {
        // Load city order from UserDefaults
        if let savedOrder = UserDefaults.standard.array(forKey: "cityOrder") as? [String] {
            // Filter out any cities that aren't in cityData anymore
            cityOrder = savedOrder.filter { cityData[$0] != nil }
        } else {
            // If no saved order, initialize with current city keys
            cityOrder = Array(cityData.keys)
        }
    }
    
    // Add a city and update the order
    func addCity(city: String, info: CityInfo) {
        cityData[city] = info
        if !cityOrder.contains(city) {
            cityOrder.append(city)
        }
    }
    
    // Remove a city and update the order
    func removeCity(city: String) {
        cityData.removeValue(forKey: city)
        if let index = cityOrder.firstIndex(of: city) {
            cityOrder.remove(at: index)
        }
    }
    
    // Move a city to a new position in the order
    func moveCity(from: IndexSet, to: Int) {
        cityOrder.move(fromOffsets: from, toOffset: to)
    }
}

struct CityInfo: Codable {
    var timeDifference: Int
    var emoji: String
    var country: String
}

//Global colors
extension Color {
    static let offblack = Color(red: 16/256, green: 16/256, blue: 16/256)
    static let darkGray = Color(red: 132/256, green: 132/256, blue: 132/256)
    static let lightGray = Color(red: 245/256, green: 245/256, blue: 245/256)
    static let offwhite = Color(red: 255/256, green: 255/256, blue: 255/256)
}

// Timezone to country mapping function
extension DataModel {
    static func getTimezoneCountryMapping() -> [String: String] {
        var tzToCountry: [String: String] = [:]
        
        guard let zoneTabPath = Bundle.main.path(forResource: "zone.tab", ofType: nil),
              let raw = try? String(contentsOfFile: zoneTabPath) else {
            // Fallback to system path if not found in bundle
            let systemZoneTabPath = "/usr/share/zoneinfo/zone.tab"
            guard let raw = try? String(contentsOfFile: systemZoneTabPath) else {
                return tzToCountry
            }
            
            for line in raw.split(separator: "\n") {
                guard !line.hasPrefix("#"),
                      let firstTab = line.firstIndex(of: "\t") else { continue }
                let countryCode = String(line[..<firstTab])
                let rest = line[line.index(after: firstTab)...]
                guard rest.split(separator: "\t").count > 1 else { continue }
                let zoneName = rest.split(separator: "\t")[1]
                tzToCountry[String(zoneName)] = countryCode
            }
            
            return tzToCountry
        }
        
        for line in raw.split(separator: "\n") {
            guard !line.hasPrefix("#"),
                  let firstTab = line.firstIndex(of: "\t") else { continue }
            let countryCode = String(line[..<firstTab])
            let rest = line[line.index(after: firstTab)...]
            guard rest.split(separator: "\t").count > 1 else { continue }
            let zoneName = rest.split(separator: "\t")[1]
            tzToCountry[String(zoneName)] = countryCode
        }
        
        return tzToCountry
    }
}
