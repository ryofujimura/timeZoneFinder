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
    
    // Generate a list of city names and their time zones from the available time zone identifiers
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
    
    // Function to get the current time in a given time zone
    func currentTimeInTimeZone(_ timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        return formatter.string(from: Date())
    }
    
    var body: some View {
        List {
            ForEach(cities) { cityTimeZone in
                HStack {
                    Text(cityTimeZone.city)
                    Spacer()
                    Text(currentTimeInTimeZone(cityTimeZone.timeZoneIdentifier))
                }
            }
            .onDelete(perform: removeCity)
            
            Section {
                TextField("New City", text: $newCity)
//                        .autocapitalization(.words)
                    .onChange(of: newCity) {
                        showSuggestions = !newCity.isEmpty
                    }
                
                if showSuggestions {
                    ForEach(filteredCities, id: \.self) { city in
                        Button(city) {
                            selectCity(city)
                        }
                    }
                }
            }
            
            Button(action: addCity) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                    Text("Add City")
                }
            }
            .disabled(newCity.isEmpty || newTimeZoneIdentifier.isEmpty)
            
        }
    }
    
    func selectCity(_ city: String) {
        newCity = city
        newTimeZoneIdentifier = cityTimeZones[city] ?? ""
        showSuggestions = false
    }
    
    func addCity() {
        if let timeZone = cityTimeZones[newCity] {
            let newCityTimeZone = CityTimeZone(city: newCity, timeZoneIdentifier: timeZone)
            cities.append(newCityTimeZone)
            newCity = ""
            newTimeZoneIdentifier = ""
            showSuggestions = false
        }
    }
    
    func removeCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }
}

struct CityTimeZone: Identifiable {
    let id = UUID()
    var city: String
    var timeZoneIdentifier: String
}


#Preview {
    CitySearchView()
}
