//
//  CitySearchView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import SwiftUI

struct BackBodyView: View {
    @ObservedObject var viewModel : DataModel
    @State private var newCity = ""
    @State private var showSuggestions = false

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
        VStack(spacing: 0) {
            searchView
            middleView
            Spacer()
            settingsBottomView
        }
//        .padding(.horizontal, 12)
//        .frame(width: 392+12+12)
    }

    var searchView: some View {
        VStack (spacing:0){
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(showSuggestions ? .black : .gray)
                TextField("Search for a city", text: $newCity)
                    .padding(.leading, 8)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(showSuggestions ? .black : .gray)
                    .onChange(of: newCity) {
                        showSuggestions = !newCity.isEmpty
                    }
                if !newCity.isEmpty {
                    Button(action: {
                        newCity = ""
                        showSuggestions = false
                    }) {
                        Text("Cancel")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.leading, 8)
//            .padding(8)
            .font(.system(.caption, design: .rounded).weight(.regular))
            .foregroundColor(.gray)
            .background(Color.white)
//            .cornerRadius(8)
            if showSuggestions {
                if filteredCities.isEmpty {
                    Text("Oops. Looks like there’s a typo :/")
                        .foregroundColor(Color(red: 132/256, green: 132/256, blue: 132/256).opacity(0.4))
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .frame(height: 110)
                } else {
                    ScrollView(showsIndicators: false) {
                        ForEach(filteredCities, id: \.self) { city in
                            suggestionView(for: city)
                                .contentShape(Rectangle())
                                .cornerRadius(25)
                                .onTapGesture {
                                    addCity(city: city)
                                }
                        }
                    }
                    .frame(maxHeight: 110)
                    .padding(.horizontal, 8)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(8)
    }

    var middleView: some View {
        VStack(spacing: 0) {
            
            Text("Your List")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundColor(.darkGray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    HStack {
                        SearchResultView(viewModel: viewModel, emoji: "📍", location: "Your Location", timeDifference: 0)
                        Image(systemName: "lock")
                            .font(.system(size: 12, design: .rounded))
                            .contentShape(Rectangle())
                    }
                    ForEach(Array(viewModel.cityData.keys.sorted()), id: \.self) { city in
                        if let cityInfo = viewModel.cityData[city] {
                            HStack {
                                SearchResultView(viewModel: viewModel, emoji: cityInfo.emoji, location: city, timeDifference: cityInfo.timeDifference)
                                Spacer()
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, design: .rounded))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        deleteSelectedCity(city: city)
                                    }
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            .frame(minHeight: 110)
        }
        .padding(8)
//        .padding(.horizontal, 8)
//        .background(Color.white)
        .cornerRadius(8)
    }

    var settingsBottomView: some View {
        VStack(spacing: 8) {
            Divider()
//                .padding(.bottom, 4)
            HStack(spacing: 0) {
                Text("Settings")
                    .padding(.horizontal, 4)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                RadioOptionButton(option: "12hr", viewModel: viewModel)
                RadioOptionButton(option: "24hr", viewModel: viewModel)
                Spacer()
            }
            .padding(.horizontal, 4)
            HStack(spacing: 4) {
                Text("About    ")
                    .padding(.horizontal, 4)
                HStack(spacing: 0) {
                    Text("Designed by ")
                        .foregroundColor(.darkGray)
                    
                    Link("Moyai", destination: URL(string: "https://www.moyaifujimura.com/")!)
                        .foregroundColor(.offblack)
                    
                    Text(". Developed by ")
                        .foregroundColor(.darkGray)
                    
                    Link("Ryo", destination: URL(string: "https://github.com/ryofujimura")!)
                        .foregroundColor(.offblack)
                    
                    Text(".")
                        .foregroundColor(.darkGray)
                }
                    .padding(.horizontal, 4)
                    .fontWeight(.regular)
                Spacer()
            }
            .padding(.horizontal, 4)
            HStack(spacing: 4) {
                Text("Quit        ")
                    .padding(.horizontal, 4)
                HStack(spacing: 0) {
                    Text("Need to quit?")
                    Text(" Click here.")
                        .onTapGesture {
                            NSApplication.shared.terminate(nil)
                        }
                }

                    .padding(.horizontal, 4)
                    .fontWeight(.regular)
                Spacer()
            }
            .padding(.horizontal, 4)
        }
        .foregroundColor(.darkGray)
        .font(.system(.caption, design: .rounded).weight(.bold))
        .padding(.bottom, 8)
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
                .foregroundColor(.offblack)
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
        formatter.dateFormat = viewModel.timeFormat == "12hr" ? "h:mm a" : "HH:mm"
        formatter.locale = Locale(identifier: "en_US")
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.timeZone = timeZone
        return formatter.string(from: Date())
    }
}

struct RadioOptionButton: View {
    let option: String
    @ObservedObject var viewModel: DataModel

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: viewModel.timeFormat == option ? "record.circle" : "circle")
                .foregroundColor(.darkGray)
                .padding(.horizontal, 4)
            Text(option)
        }
        .fontWeight(.regular)
        .padding(.trailing, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.timeFormat = option
        }
    }
}

struct CityTimeZone: Identifiable {
    let id = UUID()
    var city: String
    var timeZoneIdentifier: String
}


#Preview {
    BackBodyView(viewModel: DataModel())
}
