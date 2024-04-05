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
                HStack (spacing: 5) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Spacer()
                        CitySearchView()
                    }
                    .font(.caption)
                    .bold()
                    .padding(.leading, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.04))
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            self.settingsView.toggle()
                        }
                    }) {
                        Text("+")
                            .foregroundColor(.gray)
                    }
                    .cornerRadius(25)
                    .padding(5)
                }
//                .padding()
                .foregroundColor(.gray)
//                .frame(width: 512-100)
                .background(.white.opacity(0.2))
                .cornerRadius(25)
                .padding()
                VStack (spacing: 0 ) {
                    ForEach(cityData.sorted(by: { $0.value.timeDifference < $1.value.timeDifference }), id: \.key) { city, info in
                        if let cityInfo = cityData[city] {
                            SettingsCityView(emoji: cityInfo.emoji, location: city, timeDifference: cityInfo.timeDifference)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .padding(5)
                .background(Color.white)
                .cornerRadius(15)
//                .frame(width: 512)
                Spacer()
                Group{
                    Divider()
                    Group {
                        HStack {
                            Text("Settings:")
                            HStack {
                               OptionButton(option: "12hr", selectedOption: $selectedOption)
                               OptionButton(option: "24hr", selectedOption: $selectedOption)
                           }
                        }
                        HStack {
                            Text("About:     ")
                            Text("Designed and Developed by FUJIMURAs in California")
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .frame(width: 512-20 , alignment: .leading)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .foregroundColor(Color.gray)
            }
//            .padding()
        }
        .padding()
        .font(.headline)
        .foregroundColor(.black)
        .frame(width: 512)
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
        HStack {
            Image(systemName: selectedOption == option ? "record.circle" : "circle")
                .foregroundColor(.gray.opacity(0.5))
            Text(option)
                .foregroundColor(.gray)
        }
        .background(Color.clear)
        .frame(width: 55)
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
