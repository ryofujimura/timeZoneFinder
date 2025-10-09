//
//  DataModel.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

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
    var timeZoneID: String // Store the timezone identifier for offline use
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

// MARK: - MapKit City Resolver
func resolveCityToTimeZone(
    query: String,
    completion: @escaping ((String, TimeZone)?) -> Void
) {
    let req = MKLocalSearch.Request()
    req.naturalLanguageQuery = query
    req.resultTypes = [.address, .pointOfInterest] // cities/regions are fine

    MKLocalSearch(request: req).start { resp, err in
        if let error = err {
            print("MapKit search error for '\(query)': \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let response = resp, !response.mapItems.isEmpty else {
            print("No MapKit results found for '\(query)'")
            completion(nil)
            return
        }
        
        // Try multiple results to find one with timezone
        for item in response.mapItems {
            if let tz = item.placemark.timeZone {
                let city = item.placemark.locality ?? item.name ?? query
                let admin = item.placemark.administrativeArea
                let country = item.placemark.isoCountryCode
                
                // Create label without duplicates
                var labelComponents: [String] = [city]
                
                // Add administrative area only if it's different from city and not empty
                if let admin = admin, !admin.isEmpty && admin != city {
                    labelComponents.append(admin)
                }
                
                // Add country code only if it's different from admin area and not empty
                if let country = country, !country.isEmpty && country != admin {
                    labelComponents.append(country)
                }
                
                let label = labelComponents.joined(separator: ", ")
                print("Found timezone for '\(query)': \(tz.identifier) -> \(label)")
                completion((label, tz))
                return
            }
        }
        
        // If no timezone found, try to infer from coordinates using CLGeocoder
        if let firstItem = response.mapItems.first {
            let coordinate = firstItem.placemark.coordinate
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            // Use CLGeocoder to get timezone from coordinates
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocoding error for '\(query)': \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let placemark = placemarks?.first, let timeZone = placemark.timeZone {
                    let city = firstItem.placemark.locality ?? firstItem.name ?? query
                    let admin = firstItem.placemark.administrativeArea
                    let country = firstItem.placemark.isoCountryCode
                    
                    // Create label without duplicates
                    var labelComponents: [String] = [city]
                    
                    // Add administrative area only if it's different from city and not empty
                    if let admin = admin, !admin.isEmpty && admin != city {
                        labelComponents.append(admin)
                    }
                    
                    // Add country code only if it's different from admin area and not empty
                    if let country = country, !country.isEmpty && country != admin {
                        labelComponents.append(country)
                    }
                    
                    let label = labelComponents.joined(separator: ", ")
                    print("Inferred timezone for '\(query)': \(timeZone.identifier) -> \(label)")
                    completion((label, timeZone))
                } else {
                    print("No timezone found for '\(query)' in any MapKit result")
                    completion(nil)
                }
            }
            return
        }
        
        print("No timezone found for '\(query)' in any MapKit result")
        completion(nil)
    }
}


// MARK: - CitySearchViewModel
class CitySearchViewModel: ObservableObject {
    @Published var newCity = ""
    @Published var showSuggestions = false
    @Published var isSearchingOnline = false // Loading state for MapKit searches
    @Published var searchError: String? = nil // Error message for failed searches
    @Published var onlineSearchResults: [(String, TimeZone)] = [] // Results from MapKit search
    
    // Search history view model
    @ObservedObject var searchHistoryVM = SearchHistoryViewModel()
    
    // Main DataModel reference
    let dataModel: DataModel
    
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
            
            // Try to extract state information from timezone identifier
            var stateName = ""
            let parts = identifier.split(separator: "/")
            if parts.count >= 2 {
                // For US timezones, try to get state from the second part
                if parts[0] == "America" && parts.count >= 3 {
                    let statePart = String(parts[1])
                    // Map common US state abbreviations to full names
                    let stateMappings: [String: String] = [
                        "New_York": "NY",
                        "Chicago": "IL", 
                        "Denver": "CO",
                        "Los_Angeles": "CA",
                        "Phoenix": "AZ",
                        "Anchorage": "AK",
                        "Honolulu": "HI",
                        "Detroit": "MI",
                        "Indiana": "IN",
                        "Kentucky": "KY",
                        "Tennessee": "TN",
                        "North_Dakota": "ND",
                        "South_Dakota": "SD",
                        "Nebraska": "NE",
                        "Kansas": "KS",
                        "Texas": "TX",
                        "Oklahoma": "OK",
                        "Arkansas": "AR",
                        "Louisiana": "LA",
                        "Mississippi": "MS",
                        "Alabama": "AL",
                        "Georgia": "GA",
                        "Florida": "FL",
                        "South_Carolina": "SC",
                        "North_Carolina": "NC",
                        "Virginia": "VA",
                        "West_Virginia": "WV",
                        "Maryland": "MD",
                        "Delaware": "DE",
                        "New_Jersey": "NJ",
                        "Pennsylvania": "PA",
                        "Ohio": "OH",
                        "Michigan": "MI",
                        "Wisconsin": "WI",
                        "Minnesota": "MN",
                        "Iowa": "IA",
                        "Missouri": "MO",
                        "Illinois": "IL",
                        "New_Mexico": "NM",
                        "Arizona": "AZ",
                        "Utah": "UT",
                        "Colorado": "CO",
                        "Wyoming": "WY",
                        "Montana": "MT",
                        "California": "CA",
                        "Nevada": "NV",
                        "Oregon": "OR",
                        "Washington": "WA",
                        "Alaska": "AK",
                        "Hawaii": "HI"
                    ]
                    stateName = stateMappings[statePart] ?? ""
                }
            }
            
            // Build the display name with proper formatting
            var displayComponents: [String] = [city]
            
            if !stateName.isEmpty {
                displayComponents.append(stateName)
            }
            
            if !countryName.isEmpty {
                displayComponents.append(countryName)
            }
            
            return displayComponents.joined(separator: ", ")
        }
        return city
    }
    
    func addCity(city: String) {
        // First try offline search
        if let timeZoneIdentifier = cityTimeZones[city], let cityTimeZone = TimeZone(identifier: timeZoneIdentifier) {
            // Use the formatted display name that includes state/country information
            let formattedCityName = displayNameForCity(city: city)
            addCityWithTimeZone(city: formattedCityName, timeZone: cityTimeZone, timeZoneID: timeZoneIdentifier)
        } else {
            // Fallback to MapKit search
            searchOnlineForCity(city)
        }
    }
    
    func searchOnlineForCity(_ city: String) {
        isSearchingOnline = true
        searchError = nil
        onlineSearchResults = []
        
        resolveCityToTimeZone(query: city) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSearchingOnline = false
                
                if let (label, timeZone) = result {
                    self?.onlineSearchResults = [(label, timeZone)]
                } else {
                    // Handle no match found - show error message
                    self?.searchError = "No timezone found for '\(city)'. Please try a different city name."
                    print("No timezone found for: \(city)")
                }
            }
        }
    }
    
    func addOnlineSearchResult(_ result: (String, TimeZone)) {
        let (label, timeZone) = result
        addCityWithTimeZone(city: label, timeZone: timeZone, timeZoneID: timeZone.identifier)
        onlineSearchResults = [] // Clear results after adding
    }
    
    private func addCityWithTimeZone(city: String, timeZone: TimeZone, timeZoneID: String) {
        let localTimeZone = TimeZone.current
        let localTime = Date()
        
        let localTimeOffset = localTimeZone.secondsFromGMT(for: localTime)
        let cityTimeOffset = timeZone.secondsFromGMT(for: localTime)
        
        let timeDifference = (cityTimeOffset - localTimeOffset) / 3600
        
        // Extract city name for emoji lookup (before comma if present)
        let cityNameForEmoji = city.components(separatedBy: ",").first ?? city
        let emoji = cityEmojis[cityNameForEmoji] ?? randomEmojis.randomElement() ?? "🌍"
        
        // Store the full formatted location as the country field for display purposes
        // The location string is already properly formatted with city, state, country
        let cityInfo = CityInfo(timeDifference: timeDifference, emoji: emoji, country: city, timeZoneID: timeZoneID)
        
        // Use the full label as the key for display
        dataModel.addCity(city: city, info: cityInfo)
        
        // Add the search term to search history
        searchHistoryVM.addSearchTerm(newCity)
        
        clearSearch()
    }
    
    func deleteSelectedCity(city: String) {
        dataModel.removeCity(city: city)
    }
    
    func cityTime(for city: String) -> String {
        // First try to get timezone from stored city data (for offline cities)
        if let cityInfo = dataModel.cityData[city],
           let timeZone = TimeZone(identifier: cityInfo.timeZoneID) {
            let formatter = DateFormatter()
            formatter.dateFormat = dataModel.timeFormat == "12hr" ? "h:mm a" : "HH:mm"
            formatter.locale = Locale(identifier: "en_US")
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            formatter.timeZone = timeZone
            return formatter.string(from: Date())
        }
        
        // Fallback to original method for suggestions
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
