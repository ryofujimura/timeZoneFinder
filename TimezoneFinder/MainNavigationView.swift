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
                ForEach(locations.indices, id: \.self) { timeDifference in
                    MainCityView(location: locations[timeDifference], timeDifference: timeDifferences[timeDifference])
                        .padding()
//                        .shadow(radius: 20)
                }
            }
        }
    }
}

#Preview {
    MainNavigationView()
}
