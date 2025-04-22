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
        DispatchQueue.main.async {
            self.cityData[city] = info
            if !self.cityOrder.contains(city) {
                self.cityOrder.append(city)
            }
        }
    }
    
    // Remove a city and update the order
    func removeCity(city: String) {
        DispatchQueue.main.async {
            self.cityData.removeValue(forKey: city)
            if let index = self.cityOrder.firstIndex(of: city) {
                self.cityOrder.remove(at: index)
            }
        }
    }
    
    // Move a city to a new position in the order
    func moveCity(from: IndexSet, to: Int) {
        DispatchQueue.main.async {
            self.cityOrder.move(fromOffsets: from, toOffset: to)
        }
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

// MARK: - CitySearchViewModel
class CitySearchViewModel: ObservableObject {
    @Published var newCity = ""
    @Published var showSuggestions = false
    
    // Search history view model
    @ObservedObject var searchHistoryVM = SearchHistoryViewModel()
    
    // Main DataModel reference
    private let dataModel: DataModel
    
    // Country name mappings for better display
    let countryNameMappings: [String: String] = [
        "United States": "USA",
        "United Kingdom": "UK",
        "United Arab Emirates": "UAE",
        "China mainland": "China",
        "Congo - Brazzaville": "Congo",
    ]
    
    // Preset emojis for their locations
    let cityEmojis: [String: String] = [
        "Los Angeles": "🌴",
        "Chicago": "🍕",
        "Honolulu": "🌺",
        "Tokyo": "🍵",
        "New York": "🗽",
        "Sydney": "🦘",
        "Rome": "🍝",
        "London": "🎡",
        "San Francisco": "🌉",
        "Seattle": "☕",
        "Amsterdam": "🚲",
        "Beijing": "🐉",
        "Athens": "🏛️",
        "Mexico City": "🌮",
        "Las Vegas": "🎰",
    ]
    
    // If no preset, will be using random emoji from list
    let randomEmojis = ["🌍", "🌎", "🌏", "🏙️", "🌆", "🌇", "🏞️"]
    
    // Cache timezone to country mapping
    lazy var tzToCountry: [String: String] = {
        return DataModel.getTimezoneCountryMapping()
    }()
    
    init(dataModel: DataModel) {
        self.dataModel = dataModel
    }
    
    var cityTimeZones: [String: String] {
        var cityTimeZoneMap: [String: String] = [:]
        for identifier in TimeZone.knownTimeZoneIdentifiers {
            let parts = identifier.split(separator: "/")
            if parts.count > 1 {
                let city = parts.last!.replacingOccurrences(of: "_", with: " ")
                cityTimeZoneMap[city] = identifier
            }
        }
        return cityTimeZoneMap
    }
    
    var filteredCities: [String] {
        cityTimeZones.keys.filter { $0.lowercased().contains(newCity.lowercased()) && !newCity.isEmpty }
    }
    
    func clearSearch() {
        DispatchQueue.main.async {
            self.newCity = ""
            self.showSuggestions = false
        }
    }
    
    func getCountryNameForCity(city: String, timeZoneIdentifier: String) -> String {
        guard !timeZoneIdentifier.isEmpty else { return "" }
        
        let countryCode = tzToCountry[timeZoneIdentifier] ?? ""
        if !countryCode.isEmpty {
            let standardCountryName = Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode
            
            // Apply custom country name mapping if exists
            return countryNameMappings[standardCountryName] ?? standardCountryName
        }
        return ""
    }
    
    func displayNameForCity(city: String) -> String {
        if let identifier = cityTimeZones[city] {
            let countryName = getCountryNameForCity(city: city, timeZoneIdentifier: identifier)
            return countryName.isEmpty ? city : "\(city), \(countryName)"
        }
        return city
    }
    
    func addCity(city: String) {
        if let timeZoneIdentifier = cityTimeZones[city], let cityTimeZone = TimeZone(identifier: timeZoneIdentifier) {
            let localTimeZone = TimeZone.current
            let localTime = Date()
            
            let localTimeOffset = localTimeZone.secondsFromGMT(for: localTime)
            let cityTimeOffset = cityTimeZone.secondsFromGMT(for: localTime)
            
            let timeDifference = (cityTimeOffset - localTimeOffset) / 3600
            
            let emoji = cityEmojis[city] ?? randomEmojis.randomElement() ?? "🌍"
            
            // Get country information
            let countryName = getCountryNameForCity(city: city, timeZoneIdentifier: timeZoneIdentifier)
            
            let cityInfo = CityInfo(timeDifference: timeDifference, emoji: emoji, country: countryName)
            
            // Use original city name as the key but include country in the displayed name
            dataModel.addCity(city: city, info: cityInfo)
            
            // Add the search term to search history
            searchHistoryVM.addSearchTerm(newCity)
            
            clearSearch()
        }
    }
    
    func deleteSelectedCity(city: String) {
        dataModel.removeCity(city: city)
    }
    
    func cityTime(for city: String) -> String {
        guard let timeZoneIdentifier = cityTimeZones[city],
              let timeZone = TimeZone(identifier: timeZoneIdentifier) else {
            return "Error"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = dataModel.timeFormat == "12hr" ? "h:mm a" : "HH:mm"
        formatter.locale = Locale(identifier: "en_US")
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.timeZone = timeZone
        return formatter.string(from: Date())
    }
    
    func useHistoryItem(_ term: String) {
        newCity = term
        showSuggestions = !term.isEmpty
    }
}
