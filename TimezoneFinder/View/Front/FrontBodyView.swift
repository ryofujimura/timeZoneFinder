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
            MatchCardView(viewModel: viewModel, location: "Your Location", timeDifference: 0, emoji: "📍", globalAdjustedTime: $globalAdjustedTime)
                .id(globalAdjustedTime)
            cityListView

        }
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
                        MatchCardView(viewModel: viewModel, location: city, timeDifference: info.timeDifference, emoji: info.emoji, globalAdjustedTime: $globalAdjustedTime)
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
