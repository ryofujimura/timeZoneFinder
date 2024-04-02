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
        let dayDifference = Calendar.current.dateComponents([.day], from: currentTime, to: adjustedLocationTime).day ?? 0
        switch dayDifference {
        case 1:
            return "Tomorrow"
        case -1:
            return "Yesterday"
        default:
            return "Today"
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(25.0)
            VStack(spacing: 5) {
                TimeBarView(selectedHour: $selectedItem, hoveredHour: $hoveredItem, currentHour: Calendar.current.component(.hour, from: currentTime), timeDifference: timeDifference, globalAdjustedTime: $globalAdjustedTime)
                ZStack {
                    Text(emoji)
                        .frame(width: 460, alignment: .leading)
                        .font(.system(size: 40))
                        .opacity(0.2)
                    VStack {
                        HStack {
                            TimeDifferenceLabel(timeDifference: timeDifference, globalAdjustedTime: $globalAdjustedTime)
                            Spacer()
                            Text(locationDate)
                                .font(.caption)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(.gray.opacity(0.2))
                                .cornerRadius(40)
                        }
                        HStack {
                            Text(location)
                            Spacer()
                            Text(dateFormatter.string(from: adjustedLocationTime))
                        }
                        .font(.title)
                        .bold()
                    }
                    .padding(.leading, 40)
                }
            }
            .padding()
        }
        .frame(width: 512, height: 124)
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
                    .frame(width: 15, height: 15)
                    .bold()
                    .font(.caption2)
                    .foregroundColor(.black)
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
    @Binding var globalAdjustedTime: Int

    var adjustedTimeDifference: Int {
        timeDifference + globalAdjustedTime
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
        .font(.callout)
        .foregroundStyle(.gray)
    }
}


#Preview{
    MainCityView(location: "Tokyo", timeDifference: 16, emoji: "🗼", globalAdjustedTime: .constant(0))
}
