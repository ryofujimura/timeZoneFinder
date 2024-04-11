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
//    @State private var settingsView = true
    
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 0) {
                    TimezoneFinderView()
                    Spacer()
                    Text("☁")
                        .font(.system(size: 16, design: .rounded).weight(.bold))
                        .foregroundColor(.offblack)
                        .padding(.trailing, 8)
                        .onTapGesture {
                            viewModel.settingsView.toggle()
                        }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
                .frame(width: 416)
                
                CitySearchView(viewModel: viewModel, settingsView: $viewModel.settingsView)
                Spacer()
            }
            .opacity(viewModel.settingsView ? 0 : 1.0)
            
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    TimezoneFinderView()
                    Spacer()
                    Image(systemName: "gear")
                        .font(.system(size: 16, design: .rounded).weight(.bold))
                        .foregroundColor(.offblack)
                        .padding(.trailing, 4)
                        .onTapGesture {
                            viewModel.settingsView.toggle()
                        }
                }
                .padding(.horizontal, 12)
                .frame(width: 416)
                
                MainCityView(viewModel: viewModel, location: "Your Location", timeDifference: 0, emoji: "📍", globalAdjustedTime: $globalAdjustedTime)
                    .id(globalAdjustedTime)
                
                if viewModel.cityData.isEmpty {
                    
                    HStack (spacing: 3) {
                        Text("Hit")
                        Image(systemName: "gear")
                        Text("icon at top right to add new cities! :)")
                    }
                    .padding(.vertical, 100)
                    .foregroundColor(.darkGray.opacity(0.4))
                    .font(.system(.caption, design: .rounded).weight(.bold))

                } else {
                    VStack(spacing: 8) {
                        ForEach(viewModel.cityData.sorted(by: { $0.value.timeDifference < $1.value.timeDifference }), id: \.key) { city, info in
                            MainCityView(viewModel: viewModel, location: city, timeDifference: info.timeDifference, emoji: info.emoji, globalAdjustedTime: $globalAdjustedTime)
                                .id(globalAdjustedTime)
                        }
                    }
                }
                Spacer()
            }
            .opacity(viewModel.settingsView ? 1.0 : 0)
        }
        .padding(.top, 12)
        .frame(width: 416)
    }
    
}

struct TimezoneFinderView: View {
    var body: some View {
        Text("Timezone Finder")
            .font(.system(.body, design: .rounded).weight(.heavy))
            .foregroundColor(.offblack)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
    }
}

#Preview {
    MainNavigationView(viewModel: CityDataViewModel())
}
