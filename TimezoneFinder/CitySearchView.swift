//
//  CitySearchView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/4/24.
//
import SwiftUI

struct CitySearchView: View {
    @StateObject var viewModel: CityDataViewModel
    @State private var newCity = ""
    @State private var showSuggestions = false
    @Binding var settingsView: Bool

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
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("New City", text: $newCity)
                    .onChange(of: newCity) {
                        showSuggestions = !newCity.isEmpty
                    }
            }
            .font(.system(.caption, design: .rounded).weight(.bold))
            .foregroundColor(.gray)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)

            if showSuggestions {
                if filteredCities.isEmpty {
                    Text("No cities found")
                        .foregroundColor(.gray)
                        .frame(height: 80)
                } else {
                    ScrollView {
                        ForEach(filteredCities, id: \.self) { city in
                            suggestionView(for: city)
                                .onTapGesture {
                                    addCity(city: city)
                                }
                        }
                    }
                    .frame(height: 80)
                }
            }

            Text("Your Cities")
            ForEach(Array(viewModel.cityData.keys.sorted()), id: \.self) { city in
                if let cityInfo = viewModel.cityData[city] {
                    HStack {
                        SettingsCityView(emoji: cityInfo.emoji, location: city, timeDifference: cityInfo.timeDifference)
                        Spacer()
                        Image(systemName: "xmark")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                deleteSelectedCity(city: city)
                            }
                    }
                }
            }
        }
    }

    func suggestionView(for city: String) -> some View {
        let emoji = cityEmojis[city] ?? randomEmojis.randomElement() ?? "🌍"
        let timeZoneIdentifier = cityTimeZones[city] ?? ""
        let timeZone = TimeZone(identifier: timeZoneIdentifier)
        _ = timeZone?.secondsFromGMT() ?? 0 / 3600

        return HStack(spacing: 8) {
            Text(emoji)
                .font(.system(.callout, design: .rounded).weight(.regular))
                .opacity(0.8)
            Text(city)
            Spacer()
            Text(cityTime(for: city))
                .foregroundColor(.gray)
        }
        .font(.system(.caption, design: .rounded))
        .frame(height: 17)
        .cornerRadius(20)
    }

    func addCity(city: String) {
        if let timeZoneIdentifier = cityTimeZones[city], let cityTimeZone = TimeZone(identifier: timeZoneIdentifier) {
            let localTimeZone = TimeZone.current
            let localTime = Date()

            let localTimeOffset = localTimeZone.secondsFromGMT(for: localTime)
            let cityTimeOffset = cityTimeZone.secondsFromGMT(for: localTime)

            let timeDifference = (cityTimeOffset - localTimeOffset) / 3600

            let emoji = cityEmojis[city] ?? randomEmojis.randomElement() ?? "🌍"

            viewModel.cityData[city] = CityInfo(timeDifference: timeDifference, emoji: emoji)

            newCity = ""
            showSuggestions = false
        }
    }

    func deleteSelectedCity(city: String) {
        viewModel.cityData.removeValue(forKey: city)
    }

    func cityTime(for city: String) -> String {
        guard let timeZoneIdentifier = cityTimeZones[city],
              let timeZone = TimeZone(identifier: timeZoneIdentifier) else {
            return "Error"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = timeZone
        return formatter.string(from: Date())
    }
}

struct CityTimeZone: Identifiable {
    let id = UUID()
    var city: String
    var timeZoneIdentifier: String
}

#Preview {
    CitySearchView(viewModel: CityDataViewModel(), settingsView: .constant(true))
}
