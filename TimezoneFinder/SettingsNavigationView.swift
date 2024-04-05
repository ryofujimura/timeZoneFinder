//
//  SettingsNavigationView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/2/24.
//

import SwiftUI

struct SettingsNavigationView: View {
    @Binding var cityData: [String: (timeDifference: Int, emoji: String)]
    @Binding var settingsView: Bool
    @State private var searchText = ""
    var settings = ["12hr", "24hr"]
    @State private var selectedOption = "12hr"

    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                HStack (spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.caption)
                    Text("Textfield")
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            self.settingsView.toggle()
                        }
                }
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundColor(.gray)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                
                VStack (spacing: 4) {
                    let sortedCityArray = cityData.sorted { $0.value.timeDifference < $1.value.timeDifference }
                    ForEach(Array(sortedCityArray.enumerated()), id: \.element.key) { index, cityTuple in
                        let (city, info) = cityTuple
                        if index > 0 {
                            Divider()
                                .foregroundColor(.gray)
                        }
                        SettingsCityView(emoji: info.emoji, location: city, timeDifference: info.timeDifference)
                            .padding(8)
                    }
                }
//                .background(Color.white)
//                .cornerRadius(15)                
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
            .frame(width: 392)
        }
        .padding(12)
//        .frame(width: 416)
    }

    private func deleteCity(at offsets: IndexSet) {
        for index in offsets {
            let city = cityData.keys.sorted()[index]
            cityData.removeValue(forKey: city)
        }
    }

    private func addCity() {
        // Add logic to add a new city
    }
}

struct OptionButton: View {
    let option: String
    @Binding var selectedOption: String

    var body: some View {
        HStack (spacing: 0) {
            Image(systemName: selectedOption == option ? "record.circle" : "circle")
                .foregroundColor(.gray.opacity(0.5))
                .padding(.horizontal, 4)
            Text(option)
        }
        .fontWeight(.regular)
//        .background(Color.clear)
        .frame(width: 55, alignment: .leading)
        .contentShape(Rectangle()) // Specify the tappable area
        .onTapGesture(perform: {
            selectedOption = option
        })
    }
}

struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
    }
}


#Preview {
    SettingsNavigationView(cityData: .constant([
        "Los Angeles, USA": (timeDifference: 0, emoji: "🌴"),
        "Tokyo, Japan": (timeDifference: 17, emoji: "🗼"),
        "London, UK": (timeDifference: 8, emoji: "🎡"),
        "Sydney, Australia": (timeDifference: 18, emoji: "🌉")
    ]), settingsView: .constant(true))
}
