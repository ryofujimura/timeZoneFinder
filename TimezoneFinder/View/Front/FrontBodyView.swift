//
//  FrontBodyView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import SwiftUI

struct FrontBodyView: View {
    @ObservedObject var viewModel : DataModel
    @State private var globalAdjustedTime = 0

    var body: some View {
        VStack (spacing:12) {
            //Current location Card
            MatchCardView(viewModel: viewModel, location: "Your Location", timeDifference: 0, emoji: "📍", globalAdjustedTime: $globalAdjustedTime)
                .id(globalAdjustedTime)
            //Selected location Card(s)
            cityListView
            Spacer()

        }
    }
    
    private var cityListView: some View {
        Group {
            // If no cities are selected, show direction to add
            if viewModel.cityData.isEmpty {
                HStack(spacing: 3) {
                    Text("Hit")
                    Image(systemName: "line.3.horizontal")
                    Text("icon at top right to add new cities! :)")
                }
                .padding(.vertical, 130)
                .foregroundColor(.darkGray.opacity(0.4))
                .font(.system(.caption, design: .rounded).weight(.bold))
            }
            // Selected cities shown as each Card
            else {
                VStack(spacing: 12) {
                    ForEach(viewModel.cityData.sorted(by: { $0.value.timeDifference < $1.value.timeDifference }), id: \.key) { city, info in
                        MatchCardView(viewModel: viewModel, location: city, timeDifference: info.timeDifference, emoji: info.emoji, globalAdjustedTime: $globalAdjustedTime)
                        //Update globalAdjustedTime as globalAdjustedTime is changed on other cards
                            .id(globalAdjustedTime)
                    }
                }
            }
        }
    }
}

#Preview {
    FrontBodyView(viewModel: DataModel())
}
