//
//  MainCityView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/25/24.
//

import SwiftUI

struct MainCityView: View {
    @State private var hoveredItem: Int? = nil
    //Text("・")

    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.white)
            VStack (spacing: 5){
                HStack{
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 11))]){
                        ForEach(0...23, id: \.self) { index in
                            Group{
                                if hoveredItem == index {
                                    Text("\(index)")
                                } else {
                                    Text("・")
                                }
                            }
                            .font(.footnote)
                            .bold()
                            .frame(width: 15, height: 15)
                            //                            .padding(.horizontal)
                            .padding(1)
                            .background(hoveredItem == index ? Color.gray.opacity(0.2) : Color.clear)
                            .cornerRadius(15)
                            .onHover { isHovering in
                                hoveredItem = isHovering ? index : nil
                            }
                        }
                    }
                }
                ZStack {
                    Text("🌴")
                        .frame(width: 460, alignment: .leading)
                        .font(.system(size: 40))
                        .offset(x: -40)
                        .opacity(0.2)
                    VStack{
                        HStack{
                            Text("Current")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Spacer()
                            Text("Today")
                                .font(.caption)
                                .padding(5)
                                .background(.gray.opacity(0.2))
                                .cornerRadius(40)
                        }
                        HStack{
                            Text("Los Angels, USA")
                                .font(.title)
                                .bold()
                            Spacer()
                            Text("04:00 pm")
                                .font(.title)
                                .bold()
                            
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    MainCityView()
}
