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
    @State private var selectedOption = "24hr"

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
        VStack (spacing: 12) {
            ZStack {
                if showSuggestions{
                    Rectangle()
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                }
                VStack{
                    HStack (spacing: 0) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(showSuggestions ? .black : .gray)
                        TextField("Search for a city", text: $newCity)
                            .padding(.leading, 8)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(showSuggestions ? .black : .gray)
                            .onChange(of: newCity) {
                                showSuggestions = !newCity.isEmpty
                            }
                    }
                    .padding(8)
                    .font(.system(.caption, design: .rounded).weight(.regular))
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .cornerRadius(8)
        //            .padding(.vertical, 4)
        //            .padding(.horizontal, 8)
                    if showSuggestions {
                        if filteredCities.isEmpty {
                            Text("Oops. Looks like there’s a typo :/")
                                .foregroundColor(Color(red: 132/256, green: 132/256, blue: 132/256).opacity(0.4))
                                .font(.system(.caption, design: .rounded).weight(.bold))
                                .frame(height: 80)
                            Spacer()
                        } else {
                            ScrollView (showsIndicators: false) {
                                ForEach(filteredCities, id: \.self) { city in
                                    HStack {
                                        suggestionView(for: city)
                                            .background(Color.white)
                                            .cornerRadius(25)
                                            .onTapGesture {
                                                addCity(city: city)
                                        }
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 10)
                                    }
                                }
                            }
                            .frame(width: 392-16)
                        }
                    }
                }
            }
            VStack (spacing: 12) {
                Text("Your List")
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundColor(.gray)
                    .frame(width: 392-16, alignment: .leading)
                HStack{
                    SettingsCityView(emoji: "📍", location: "Your Location", timeDifference: 0)
                    Image(systemName: "lock.fill")
                        .font(.system(size:8, design: .rounded).weight(.bold))
                        .contentShape(Rectangle())
                }
                .frame(width: 392-16)
                ForEach(Array(viewModel.cityData.keys.sorted()), id: \.self) { city in
                    if let cityInfo = viewModel.cityData[city] {
                        HStack {
                            SettingsCityView(emoji: cityInfo.emoji, location: city, timeDifference: cityInfo.timeDifference)
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size:8, design: .rounded).weight(.bold))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    deleteSelectedCity(city: city)
                                }
                        }
                    }
                }
                .frame(width: 392-16)
            }
//            .padding(.horizontal, 8)
            
            
            Spacer()
            VStack (spacing: 4 ) {
                Divider()
                HStack (spacing: 0) {
                    Text("Settings")
                        .padding(.horizontal, 4)
                        .font(.system(.caption, design: .rounded).weight(.bold))
                    OptionButton(option: "12hr", selectedOption: $selectedOption)
                    OptionButton(option: "24hr", selectedOption: $selectedOption)
                    Spacer()
                }
                .padding(.horizontal, 4)
                HStack (spacing: 4) {
                    Text("About    ")
                        .padding(.horizontal, 4)
//                            .frame(width: 392-322, alignment: .leading)
                    Text("Designed and Developed by フジムラ3 in California")
                        .padding(.horizontal, 4)
                        .fontWeight(.regular)
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
            .foregroundColor(.gray)
            .font(.system(.caption, design: .rounded).weight(.bold))
        }
        .padding(12)
        .frame(width: 392+12+12)
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
                .foregroundColor(.black)
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
