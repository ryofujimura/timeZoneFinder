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
    
    var body: some View {
        ZStack{
//            Rectangle()
//                .foregroundColor(.white.opacity(0.9))
            VStack {
                HStack (spacing: 0 ) {
                    TimezoneFinderView()
                    Spacer()
                    Image(systemName: "globe")
                        .frame(width: 12, height: 12, alignment: .center)
                        .padding(.trailing, 8)
                        .onTapGesture {
                            settingsView.toggle()
                        }
                }
                .padding(.horizontal, 12)
                .frame(width: 416)
                CitySearchView(viewModel: viewModel, settingsView: $settingsView)
//                SettingsNavigationView(cityData: $cityData, settingsView: $settingsView)
                Spacer()
            }
            .opacity(settingsView ? 0 : 1.0)
            .rotation3DEffect(.degrees(settingsView ? 0 : 0), axis: (x: 0, y: 1, z: 0))
            VStack (spacing: 12 ) {
                HStack (spacing: 0 ) {
                    TimezoneFinderView()
                    Spacer()
                    Image(systemName: "plus")
                        .bold()
                        .frame(width: 12, height: 12, alignment: .center)
                        .foregroundColor(Color(red: 16/256, green: 16/256, blue: 16/256))
                        .padding(.trailing, 8)
                        .onTapGesture {
                            settingsView.toggle()
                        }
                }
                .padding(.horizontal, 12)
                .frame(width: 416)
                MainCityView(location: "Your Location", timeDifference: 0, emoji: "📍", globalAdjustedTime: $globalAdjustedTime)
                    .id(globalAdjustedTime)
//                Divider()
//                    .padding(.horizontal, 12)
                if viewModel.cityData.isEmpty {
                    Text("Hit + icon at top right\nto add new cities! :)")
                        .padding(.vertical, 100)
                        .foregroundColor(Color(red: 132/256, green: 132/256, blue: 132/256).opacity(0.4))
                        .font(.system(.caption, design: .rounded).weight(.bold))
                } else {
                    VStack{
                        ForEach(viewModel.cityData.sorted(by: { $0.value.timeDifference < $1.value.timeDifference }), id: \.key) { city, info in
                            MainCityView(location: city, timeDifference: info.timeDifference, emoji: info.emoji, globalAdjustedTime: $globalAdjustedTime)
                                .id(globalAdjustedTime)
                        }
                    }
                }
                Spacer()
            }
            .opacity(settingsView ? 1.0 : 0)
            .rotation3DEffect(.degrees(settingsView ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
        .padding(.top, 12)
        .frame(width: 416)
    }
}

struct TimezoneFinderView: View {
    var body: some View {
        Text("Timezone Finder")
            .font(.system(.body, design: .rounded).weight(.heavy))
            .kerning(0.68)
            .foregroundColor(Color(red: 132/256, green: 132/256, blue: 132/256))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
    }
}

#Preview {
    MainNavigationView(viewModel: CityDataViewModel())
}
