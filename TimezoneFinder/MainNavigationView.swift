//
//  MainNavigationView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/26/24.
//

import SwiftUI

struct MainNavigationView: View {
    @State private var cityData: [String: (timeDifference: Int, emoji: String)] = [
        "London, UK": (timeDifference: 8, emoji: "🦁"),
        "Honolulu, USA": (timeDifference: -3, emoji: "🌺"),
        "Chicago, USA": (timeDifference: 2, emoji: "🍕"),
        "Tokyo, Japan": (timeDifference: 16, emoji: "🗼")
    ]
    @State private var globalAdjustedTime = 0
    @State private var settingsView = true
    
    @State private var deviceLocation = "Los Angeles, USA"
    @State private var deviceEmoji = "🌴"
    
    var body: some View {
        ZStack{
//            Rectangle()
//                .foregroundColor(.white.opacity(0.9))
            VStack {
                SettingsNavigationView(cityData: $cityData, settingsView: $settingsView)
                Spacer()
            }
            .opacity(settingsView ? 0 : 1.0)
            .rotation3DEffect(.degrees(settingsView ? 0 : 0), axis: (x: 0, y: 1, z: 0))
            VStack (spacing: 12 ) {
                HStack (spacing: 0 ) {
                    Text("Timezone Finder")
                        .font(.system(.body, design: .rounded).weight(.heavy))
                        .kerning(1.04)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                    Spacer()
                    Image(systemName: "plus")
                        .frame(width: 12, height: 12, alignment: .center)
                        .onTapGesture {
                            self.settingsView.toggle()
                        }
                }
                .padding(.trailing, 8)
                .frame(width: 416-12-12)
//                .frame(width: 416-12-12)
                ForEach(cityData.sorted(by: { $0.value.timeDifference < $1.value.timeDifference }), id: \.key) { city, info in
                    if let cityInfo = cityData[city] {
                        MainCityView(location: city, timeDifference: cityInfo.timeDifference, emoji: cityInfo.emoji, globalAdjustedTime: $globalAdjustedTime)
                            .id(globalAdjustedTime)
                    }
                }
            }
            .opacity(settingsView ? 1.0 : 0)
            .rotation3DEffect(.degrees(settingsView ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: 416-12-12)
        .padding()
    }
}

#Preview {
    MainNavigationView()
}
