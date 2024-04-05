//
//  MainNavigationView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/26/24.
//

import SwiftUI

struct MainNavigationView: View {
    @StateObject var viewModel = CityDataViewModel()
    
    @State private var globalAdjustedTime = 0
    @State private var settingsView = true
    
    @State private var deviceLocation = "Los Angeles, USA"
    @State private var deviceEmoji = "🌴"
    
    var body: some View {
        ZStack{
//            Rectangle()
//                .foregroundColor(.white.opacity(0.9))
            VStack {
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
                            settingsView.toggle()
                        }
                }
                .padding(.trailing, 8)
                CitySearchView(viewModel: viewModel, settingsView: $settingsView)
//                SettingsNavigationView(cityData: $cityData, settingsView: $settingsView)
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
                            settingsView.toggle()
                        }
                }
                .padding(.trailing, 8)
//                .frame(width: 416-12-12)
                ForEach(viewModel.cityData.sorted(by: { $0.value.timeDifference < $1.value.timeDifference }), id: \.key) { city, info in
                    MainCityView(location: city, timeDifference: info.timeDifference, emoji: info.emoji, globalAdjustedTime: $globalAdjustedTime)
                        .id(globalAdjustedTime)
                }
                Spacer()
            }
            .opacity(settingsView ? 1.0 : 0)
            .rotation3DEffect(.degrees(settingsView ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: 416-12-12)
        .padding()
    }
}

#Preview {
    MainNavigationView(viewModel: CityDataViewModel())
}
