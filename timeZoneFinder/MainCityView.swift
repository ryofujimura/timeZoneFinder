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
    let hour: Int = Calendar.current.component(.hour, from: Date())
    let minute: Int = Calendar.current.component(.minute, from: Date())
//    @State private var timeDifference = "Current"
//    @State private var location = "Los Angeles, CA"
    @State private var locationTime = "no time"
    @State private var locationDate = "Today"
    var location: String
    var timeDifference: Int

    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(25.0)
            VStack (spacing: 5){
                HStack{
                    ForEach(0...23, id: \.self) { index in
                        Group{
                            if selectedItem == index{
                                Text("\(index)")
                                    .font(.footnote)
                                    .frame(width: 15, height: 15)
                                    .padding(2)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(15)
                                
                            } else if hoveredItem == index {
                                Text("\(index)")
                                    .font(.footnote)
                                    .frame(width: 15, height: 15)
                                    .padding(2)
                            }
                            else {
                                Text("・")
                                    .frame(width: 15, height: 15)
                                    .font(.caption)
                            }
                        }
                        .bold()
                        .onHover{_ in 
                            hoveredItem = index
                        }
                        .onTapGesture {
                            selectedItem = index
                        }
                        .onAppear {
                            if selectedItem == -1 {
                                selectedItem = hour
                            }
                        }
                    }
                }
                ZStack {
                    Text("🌴")
                        .frame(width: 460, alignment: .leading)
                        .font(.system(size: 40))
//                        .offset(x: -60)
                        .opacity(0.2)
                    VStack{
                        HStack{
                            Group{
                                if timeDifference == 0{
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
                            Group{
                                if hour+timeDifference > 24 {
                                    Text("Tomorrow")
                                } else if hour+timeDifference < 24{
                                    Text("Yesterday")
                                } else {
                                    Text("Today")
                                }
                            }
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
                            Group{
                                if hour+timeDifference > 24 {
                                    Text(String(format: "%02d:%02d", hour+timeDifference-24, minute))
                                } else if hour+timeDifference < 0{
                                    Text(String(format: "%02d:%02d", hour+timeDifference+24, minute))
                                } else {
                                    Text(String(format: "%02d:%02d", hour+timeDifference, minute))
                                }
                            }
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

#Preview {
    MainCityView(location: "Los Angeles, USA", timeDifference: 0)
}
