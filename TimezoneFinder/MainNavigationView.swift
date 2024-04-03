//
//  MainNavigationView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/26/24.
//

import SwiftUI

struct MainNavigationView: View {
    @State private var cityData: [String: (timeDifference: Int, emoji: String)] = [
        "Los Angeles, USA": (timeDifference: 0, emoji: "🌴"),
        "Honolulu, USA": (timeDifference: -3, emoji: "🌺"),
        "Chicago, USA": (timeDifference: 2, emoji: "🍕"),
        "Tokyo, Japan": (timeDifference: 16, emoji: "🗼")
    ]
    @State private var globalAdjustedTime = 0
    @State private var settingsView = true
    
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
            VStack (spacing: 20 ) {
                HStack{
                    Text("Timezone Finder")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            self.settingsView.toggle()
                        }
                    }) {
                        Text("+")
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                ForEach(cityData.sorted(by: { $0.value.timeDifference < $1.value.timeDifference }), id: \.key) { city, info in
                    if let cityInfo = cityData[city] {
                        MainCityView(location: city, timeDifference: cityInfo.timeDifference, emoji: cityInfo.emoji, globalAdjustedTime: $globalAdjustedTime)
                            .id(globalAdjustedTime)
                    }
                }
            }
            .padding()
//            .frame(width: 512-100)
            .opacity(settingsView ? 1.0 : 0)
            .rotation3DEffect(.degrees(settingsView ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
        .foregroundColor(.black)
        .background(Color.white.opacity(0.9))
        .frame(width: 512)
        .padding()
    }
}

#Preview {
    MainNavigationView()
}
