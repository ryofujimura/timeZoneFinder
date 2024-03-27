//
//  MainCityView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/25/24.
//

import SwiftUI
import Foundation

struct MainCityView: View {
    @State private var hoveredItem: Int? = nil
    @State private var selectedItem = -1
    @State var hour: Int = Calendar.current.component(.hour, from: Date())
    @State var minute: Int = Calendar.current.component(.minute, from: Date())
    @State private var locationDate = "Today"
    @State private var locationHour: Int = 0
//    @State private var adjustedTime: Int = 0
    var location: String
    var timeDifference: Int
    var emoji: String
    @Binding var globalAdjustedTime: Int

    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(25.0)
            VStack (spacing: 5){
                HStack (spacing: 0){
                    ForEach(0...23, id: \.self) { index in
                        Group{
                            if locationHour == index {
                                if selectedItem == locationHour{
                                    Text("\(locationHour)")
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                } else {
                                    Text("\(locationHour)")
                                        .foregroundStyle(.gray)
                                }
                            } else {
                                if selectedItem == index{
                                    Text("\(index)")
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                } else if hoveredItem == index {
                                    Text("\(index)")
                                } else {
                                    Text("・")
                                }
                            }
                        }
                        .frame(width: 15, height: 15)
                        .bold()
                        .font(.caption2)
                        .foregroundColor(.black)
                        .onHover {_ in
                            hoveredItem = index
                        }
                        .onTapGesture {
                            selectedItem = index
                            globalAdjustedTime = index - locationHour
                        }
                        .onAppear {
                            globalAdjustedTime = locationHour-index
                            locationHour = hour+timeDifference
                            if locationHour > 24 {
                                locationDate = "Tomorrow"
                                locationHour -= 24
                            } else if locationHour < 0 {
                                locationDate = "Yesterday"
                                locationHour += 24
                            }
                            selectedItem = locationHour
                        }
                    }
                }
                .onHover{ hovering in
                    if !hovering {
                        hoveredItem = nil
                    }
                }
                ZStack {
                    Text(emoji)
                        .frame(width: 460, alignment: .leading)
                        .font(.system(size: 40))
//                        .offset(x: -60)
                        .opacity(0.2)
                    VStack{
                        HStack{
                            Group{
                                if timeDifference == 0 {
                                    Text("Current")
                                } else if timeDifference > 0 {
                                    Text("+\(timeDifference)hrs")
                                } else {
                                    Text("\(timeDifference)hrs")
                                }
                            }
                            .font(.callout)
                            .foregroundStyle(.gray)
                            Spacer()
                            Text(locationDate)
                                .font(.caption)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(.gray.opacity(0.2))
                                .cornerRadius(40)
                        }
                        HStack{
                            Text(location)
                                .font(.title)
                                .bold()
                            Spacer()
                            Text(String(format: "%02d:%02d", locationHour+globalAdjustedTime, minute))
                                .font(.title)
                                .bold()
                        }
                    }
                    .padding(.leading, 40)
                }
            }
            .padding()
        }
        .frame(width: 512, height: 124)
    }
}
