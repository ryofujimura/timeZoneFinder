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
                // Use List for built-in reordering UI/animation support
                List {
                    // Iterate directly over the cityData array (which is [CityEntry])
                    // CityEntry is Identifiable by its UUID 'id' property
                    ForEach(viewModel.cityData) { entry in
                        MatchCardView(viewModel: viewModel, location: entry.name, timeDifference: entry.info.timeDifference, emoji: entry.info.emoji, globalAdjustedTime: $globalAdjustedTime)
                        //Update globalAdjustedTime as globalAdjustedTime is changed on other cards
                            .id(globalAdjustedTime) // Consider if this .id is still needed or correct here
                            // Remove default List row padding/background if necessary
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .padding(.bottom, 12) // Add spacing between cards
                    }
                    // Add the .onMove modifier to enable drag-and-drop
                    .onMove(perform: viewModel.moveCity)
                    // Remove default List row padding/background for the move action row if necessary
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain) // Use plain style to remove default List styling
                .frame(height: CGFloat(viewModel.cityData.count) * 112) // Adjust height dynamically (assuming card height ~100 + padding)
            }
        }
    }
}

#Preview {
    FrontBodyView(viewModel: DataModel())
}
