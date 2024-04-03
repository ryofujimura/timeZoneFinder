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

    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                HStack (spacing: 5) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search City", text: $searchText)
                    }
                    .font(.caption)
                    .bold()
                    .padding(.leading, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(20)
                    .overlay(
                        HStack {
                            if !searchText.isEmpty {
                                Button(action: { self.searchText = "" }) {
                                    Image(systemName: "multiply.circle")
                                }
                            }
                        }
                    )
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
                .padding()
                .background(Color.white)
                .cornerRadius(15)
//                .frame(width: 512)
                Spacer()
            }
            .padding()
        }
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

struct CityDetailView: View {
    var city: String

    var body: some View {
        VStack {
            Text("Hello")
            Text(city)
        }
        .padding()
    }
}

struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
//            .padding(10)
//            .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
//            .background(Color.black.opacity(0.2))
//            .cornerRadius(10)
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
           
//            .shadow(color: .gray, radius: 10)
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
