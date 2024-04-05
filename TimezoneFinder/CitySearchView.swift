//
//  CitySearchView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/4/24.
//

import SwiftUI

struct CitySearchView: View {
    @State private var cities: [CityTimeZone] = []
    @State private var newCity = ""
    @State private var newTimeZoneIdentifier = ""
    @State private var showSuggestions = false
    @State private var cityData: [String: CityInfo] = [:] {
        didSet {
            saveCityData()
        }
    }

    init() {
        loadCityData()
    }
    
    let cityEmojis: [String: String] = [
        "Los Angeles": "🌴",
        "Chicago": "🍕",
        "Honolulu": "🌺",
        "Tokyo": "🗼",
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

    let randomEmojis = ["🌍", "🌎", "🌏", "🏙️", "🌆", "🌇", "🏞️"]
    
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
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("New City", text: $newCity)
                        .onChange(of: newCity) {
                            showSuggestions = !newCity.isEmpty
                    }
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                }
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundColor(.gray)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                
                if showSuggestions {
                    if filteredCities.isEmpty {
                        Text("No cities found")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(filteredCities, id: \.self) { city in
                            HStack {
                                Text(city)
                                Spacer()
                                Button(action: { addCity(city: city) }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Selected Cities")) {
                ForEach(Array(cityData.keys.sorted()), id: \.self) { city in
                    if let cityInfo = cityData[city] {
                        HStack {
                            SettingsCityView(emoji: cityInfo.emoji, location: city, timeDifference: cityInfo.timeDifference)
                            Spacer()
                            Button(action: { deleteSelectedCity(city: city) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addCity(city: String) {
        if let timeZone = cityTimeZones[city] {
            // Get the current hour in the local time zone
            let localHour = Calendar.current.component(.hour, from: Date())
            
            // Get the current hour in the selected city's time zone
            if let cityTimeZone = TimeZone(identifier: timeZone) {
                var cityDateComponents = Calendar.current.dateComponents(in: cityTimeZone, from: Date())
                let cityHour = cityDateComponents.hour ?? 0
                
                // Calculate the time difference
                let timeDifference = cityHour - localHour
                
                // Assign an emoji
                let emoji = cityEmojis[city] ?? randomEmojis.randomElement() ?? "🌍"
                
                // Update the cityData dictionary
                cityData[city] = CityInfo(timeDifference: timeDifference, emoji: emoji)
            }
            
            newCity = ""
            newTimeZoneIdentifier = ""
            showSuggestions = false
        }
    }

    
    func deleteSelectedCity(city: String) {
        cityData.removeValue(forKey: city)
    }
    
    func saveCityData() {
        if let encoded = try? JSONEncoder().encode(cityData) {
            UserDefaults.standard.set(encoded, forKey: "cityData")
        }
    }
    
    func loadCityData() {
        if let savedCityData = UserDefaults.standard.data(forKey: "cityData"),
           let decodedCityData = try? JSONDecoder().decode([String: CityInfo].self, from: savedCityData) {
            cityData = decodedCityData
        }
    }
}

struct CityInfo: Codable {
    var timeDifference: Int
    var emoji: String
}

struct CityTimeZone: Identifiable {
    let id = UUID()
    var city: String
    var timeZoneIdentifier: String
}

struct SettingsCityViewone: View {
    var emoji: String
    var location: String
    var timeDifference: Int

    var body: some View {
        HStack {
            Text("\(emoji) \(location)")
            Spacer()
            Text("Time difference: \(timeDifference) hours")
        }
    }
}

#Preview {
    CitySearchView()
}
