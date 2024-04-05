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
    @State private var selectedItem: Int?
    @State private var currentTime = Date()
    var location: String
    var timeDifference: Int
    var emoji: String
    @State var hour: Int = Calendar.current.component(.hour, from: Date())
    @Binding var globalAdjustedTime: Int

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var adjustedLocationTime: Date {
        return Calendar.current.date(byAdding: .hour, value: timeDifference + globalAdjustedTime, to: currentTime) ?? Date()
    }

    private var locationDate: String {
        _ = (hour + timeDifference + globalAdjustedTime) % 24
        let dayDifference = (hour + timeDifference + globalAdjustedTime) / 24
        switch dayDifference {
        case 1, -23:
            return "Tomorrow"
        case -1, 23:
            return "Yesterday"
        default:
            return "Today"
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(8)
            VStack(spacing: 4) {
                TimeBarView(selectedHour: $selectedItem, hoveredHour: $hoveredItem, currentHour: Calendar.current.component(.hour, from: currentTime), timeDifference: timeDifference, globalAdjustedTime: $globalAdjustedTime)
                HStack (spacing: 0) {
                    Text(emoji)
                        .opacity(0.2)
                        .font(.system(size: 48))
                        .frame(width: 48)
                        .offset(x:-24)
                        .clipped()
                        .frame(width: 24)
                        .offset(x:12)
                    VStack (spacing: 2) {
                        HStack (spacing: 0) {
                            Text(locationDate)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.gray.opacity(0.2))
                                .cornerRadius(40)
                            Spacer()
                            TimeDifferenceLabel(timeDifference: timeDifference, globalAdjustedTime: globalAdjustedTime)
                        }
                        .foregroundStyle(.gray)
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .kerning(0.8)
                        HStack (spacing: 0) {
                            Text(location)
                                .padding(.vertical, 1.5)
//                                Text("トウキョウ")
//                                    .opacity(0.2)
//                                    .blur(radius: 1)
//                                    .offset(x:60, y:8)
                            Spacer()
                            Text(dateFormatter.string(from: adjustedLocationTime))
                        }
                        .font(.system(.title2, design: .rounded).weight(.heavy))
                        .kerning(0.62)
                    }
                    .padding(.horizontal, 8)
//                    .padding(.vertical, 6)
                    .frame(width: 392-24)
                }
            }
//            .foregroundColor(.black)
        }
        
        .frame(width: 392, height: 84)
        .onAppear {
            // Set the initial selected hour based on the current time and time difference
            let initialHour = Calendar.current.component(.hour, from: adjustedLocationTime)
            selectedItem = initialHour
        }
    }
}

struct TimeBarView: View {
    @Binding var selectedHour: Int?
    @Binding var hoveredHour: Int?
    let currentHour: Int
    let timeDifference: Int
    @Binding var globalAdjustedTime: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { index in
                Text(hourLabel(for: index))
                    .padding(1)
                    .frame(width: 16, height: 16)
                    .bold()
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .background(hourBackground(for: index))
                    .cornerRadius(15)
                    .onHover { isHovering in
                        hoveredHour = isHovering ? index : nil
                    }
                    .onTapGesture {
                        selectedHour = index
                        globalAdjustedTime = index - (currentHour + timeDifference)
                    }
            }
        }
    }

    private func hourLabel(for index: Int) -> String {
        if index == (currentHour + timeDifference) % 24 {
            return String(index)
        } else if let selected = selectedHour, selected == index {
            return String(index)
        } else if let hovered = hoveredHour, hovered == index {
            return String(index)
        } else {
            return "・"
        }
    }

    private func hourBackground(for index: Int) -> Color {
        if index == (currentHour + timeDifference) % 24 {
            if let selected = selectedHour, selected == index{
                return Color.gray.opacity(0.2)
            }
            return Color.clear
        } else if let selected = selectedHour, selected == index {
            return Color.gray.opacity(0.2)
        } else {
            return Color.clear
        }
    }
}

struct TimeDifferenceLabel: View {
    let timeDifference: Int
    let globalAdjustedTime: Int

    var adjustedTimeDifference: Int {
        return timeDifference + globalAdjustedTime
    }

    var body: some View {
        Group {
            if adjustedTimeDifference == 0 {
                Text("Current")
            } else if adjustedTimeDifference > 0 {
                Text("+\(adjustedTimeDifference)hrs")
            } else {
                Text("\(adjustedTimeDifference)hrs")
            }
        }
    }
}

#Preview{
    MainCityView(location: "Tokyo, Japan", timeDifference: 5, emoji: "🗼", globalAdjustedTime: .constant(0))
}
