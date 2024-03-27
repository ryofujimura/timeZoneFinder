//
//  MainNavigationView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/26/24.
//

import SwiftUI

struct MainNavigationView: View {
    @State private var locations = ["Los Angeles, USA", "Honolulu, USA", "Chicago, USA", "Tokyo, Japan"]
    @State private var timeDifferences = [0, -3, 2, 16]
    @State private var emojis = ["🌴", "🌺", "🍕", "🗼"]
    @State private var globalAdjustedTime = 0
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.gray.opacity(0.05))
//                .frame(width: 550, height: 700)
            VStack{
                HStack{
                    Text("Timezone Finder")
                        .font(.title3)
                        .bold()
                        .padding()
                    Button(action: {}, label: {
                        Text("+")
                    })
                }
                ForEach(locations.indices, id: \.self) { city in
                    MainCityView(location: locations[city], timeDifference: timeDifferences[city], emoji: emojis[city], globalAdjustedTime: $globalAdjustedTime)
//                        .shadow(radius: 20)
                }
            }
            .padding()
        }
        .padding(.vertical, 20)
    }
}
//
//
//struct MainNavigationView: View {
//    @State private var locationsData = [
//        "Los Angeles, USA": (timeDifference: 0, emoji: "🌴"),
//        "Honolulu, USA": (timeDifference: -3, emoji: "🍝"),
//        "Chicago, USA": (timeDifference: 2, emoji: "🦘"),
//        "Tokyo, Japan": (timeDifference: 16, emoji: "👾")
//    ]
//    @State private var globalAdjustedTime = 0
//
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .foregroundColor(.gray.opacity(0.05))
//            VStack {
//                HStack {
//                    Text("Timezone Finder")
//                        .font(.title3)
//                        .bold()
//                        .padding()
//                    Button(action: {}, label: {
//                        Text("+")
//                    })
//                }
//                ForEach(Array(locationsData.keys), id: \.self) { location in
//                    if let data = locationsData[location] {
//                        MainCityView(location: location, timeDifference: data.timeDifference, globalAdjustedTime: $globalAdjustedTime, emoji: data.emoji)
//                    }
//                }
//            }
//            .padding()
//        }
//        .padding(.vertical, 20)
//    }
//}
//

#Preview {
    MainNavigationView()
}
