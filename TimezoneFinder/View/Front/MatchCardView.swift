//
//  MatchCardView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import SwiftUI

// Each individual card of City Card
struct MatchCardView: View {

    @ObservedObject var viewModel : DataModel

    @State private var hoveredItem: Int? = nil
    @State private var selectedItem: Int?
    @State private var currentTime = Date()
    
    var location: String
    var timeDifference: Int
    var emoji: String
    
    @State var hour: Int = Calendar.current.component(.hour, from: Date())
    @Binding var globalAdjustedTime: Int

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        // Time format 01:00 pm or 13:00
        formatter.dateFormat = viewModel.timeFormat == "12hr" ? "h:mm a" : "HH:mm"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }

    private var adjustedLocationTime: Date {
        return Calendar.current.date(byAdding: .hour, value: timeDifference + globalAdjustedTime, to: currentTime) ?? Date()
    }
    
    private var locationDate: String {
        let dateFormatter = DateFormatter()
        // Date format in April 1, 2024
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let adjustedDate = Calendar.current.date(byAdding: .hour, value: timeDifference + globalAdjustedTime, to: currentTime) ?? Date()
        return dateFormatter.string(from: adjustedDate)
    }


    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white.opacity(0.8))
                .cornerRadius(8)
            VStack(spacing: 4) {
                TimeBarView(
                    selectedHour: $selectedItem,
                    hoveredHour: $hoveredItem,
                    viewModel: viewModel,
                    currentHour: Calendar.current.component(.hour, from: Date()),
                    timeDifference: timeDifference,
                    globalAdjustedTime: $globalAdjustedTime
                )

                HStack (spacing: 0) {
                    Text(emoji)
                        .opacity(0.2)
                        .font(.system(size: 48))
                        .frame(width: 48)
                        .offset(x:-24)
                        .clipped()
                        .frame(width: 24)
                        .offset(x:12)
                    VStack (spacing: 4) {
                        HStack (spacing: 0) {
                            Text(locationDate)
                            Spacer()
                            TimeDifferenceLabel(timeDifference: timeDifference, globalAdjustedTime: globalAdjustedTime)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.lightGray)
                                .cornerRadius(40)
                        }
                        .foregroundColor(.darkGray)
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
                        .kerning(0.68)
                    }
                    .padding(.horizontal, 8)
                    .frame(width: 392-24)
                }
            }
        }
        .foregroundColor(.offblack)
        .frame(width: 392, height: 84)
        .onAppear {
            let initialHour = Calendar.current.component(.hour, from: adjustedLocationTime)
            selectedItem = initialHour
        }
    }
}

struct TimeBarView: View {
    @Binding var selectedHour: Int?
    @Binding var hoveredHour: Int?
    @ObservedObject var viewModel: DataModel
    let currentHour: Int
    let timeDifference: Int
    @Binding var globalAdjustedTime: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { index in
                hourLabel(for: index)
                    .padding(1)
                    .frame(width: 15.5, height: 16)
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

    private func hourLabel(for index: Int) -> some View {
        let isCurrentHour = index == (currentHour + timeDifference) % 24
        let isSelected = selectedHour == index
        let isHovered = hoveredHour == index

        let displayText: String
        if isSelected || isHovered {
            displayText = String(index % (viewModel.timeFormat == "12hr" ? 12 : 24))
        } else {
            displayText = isCurrentHour ? String(index % (viewModel.timeFormat == "12hr" ? 12 : 24)) : "・"
        }
        let fontColor: Color = isSelected || isHovered ? .offblack : (isCurrentHour ? .darkGray : .offblack)

        return Text(displayText)
            .foregroundColor(fontColor)
    }



    private func hourBackground(for index: Int) -> Color {
        if index == (currentHour + timeDifference) % 24 {
            if let selected = selectedHour, selected == index{
                return .lightGray
            }
            return Color.clear
        } else if let selected = selectedHour, selected == index {
            return .lightGray
        } else {
            return Color.clear
        }
    }
}

struct TimeDifferenceLabel: View {
    let timeDifference: Int
    let globalAdjustedTime: Int

    var adjustedTimeDifference: Int {
        return timeDifference /*+ globalAdjustedTime*/
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


#Preview {
    MatchCardView(viewModel: DataModel(), location: "Tokyo, Japan", timeDifference: 5, emoji: "🌴", globalAdjustedTime: .constant(1))
}
