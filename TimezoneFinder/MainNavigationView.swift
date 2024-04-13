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

    var body: some View {
        ZStack {
            Group {
                if !viewModel.settingsView {
                    mainContent
                } else {
                    settingsContent
                }
            }
        }
        .padding(.top, 12)
        .frame(width: 416)
    }
    
    private var mainContent: some View {
        VStack {
            headerView(icon: "circle", action: {
                viewModel.settingsView.toggle()
            })
            
            CitySearchView(viewModel: viewModel)
            Spacer()
        }
    }

    private var settingsContent: some View {
        VStack(spacing: 12) {
            headerView(icon: "gear", action: {
                viewModel.settingsView.toggle()
            })

            MainCityView(viewModel: viewModel, location: "Your Location", timeDifference: 0, emoji: "📍", globalAdjustedTime: $globalAdjustedTime)
                .id(globalAdjustedTime)
            
            cityListView
            Spacer()
        }
    }

    private func headerView(icon: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 0) {
            TimezoneFinderView()
            Spacer()
            Image(systemName: icon) // Using system image instead of text
                .font(.system(size: 16, design: .rounded).weight(.bold))
                .foregroundColor(.offblack)
                .padding(.trailing, 8)
                .onTapGesture(perform: action)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
        .frame(width: 416)
    }

    private var cityListView: some View {
        Group {
            if viewModel.cityData.isEmpty {
                HStack(spacing: 3) {
                    Text("Hit")
                    Image(systemName: "gear")
                    Text("icon at top right to add new cities! :)")
                }
                .padding(.vertical, 100)
                .foregroundColor(.darkGray.opacity(0.4))
                .font(.system(.caption, design: .rounded).weight(.bold))
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.cityData.sorted(by: { $0.value.timeDifference < $1.value.timeDifference }), id: \.key) { city, info in
                        MainCityView(viewModel: viewModel, location: city, timeDifference: info.timeDifference, emoji: info.emoji, globalAdjustedTime: $globalAdjustedTime)
                            .id(globalAdjustedTime)
                    }
                }
            }
        }
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

// Preview
#Preview {
    MainNavigationView(viewModel: CityDataViewModel())
}
