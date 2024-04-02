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
//                        .shadow(radius: 14)
                }
            }
            .padding()
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    MainNavigationView()
}
