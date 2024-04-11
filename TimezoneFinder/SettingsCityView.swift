//
//  SettingsCityView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/2/24.
//

import SwiftUI

struct SettingsCityView: View {
    @ObservedObject var viewModel: CityDataViewModel
    var emoji: String
    var location: String
    var timeDifference: Int
    
    var cityTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = viewModel.timeFormat == "12hr" ? "h:mm a" : "HH:mm"
        formatter.locale = Locale(identifier: "en_US")
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        if let adjustedDate = Calendar.current.date(byAdding: .hour, value: timeDifference, to: Date()) {
            return formatter.string(from: adjustedDate)
        } else {
            return "Error"
        }
    }
    
    var body: some View {
        HStack (spacing: 8) {
            Text(emoji)
                .font(.system(.callout, design: .rounded).weight(.regular))
                .opacity(0.8)
            Text(location)
            Spacer()
            Group {
                if timeDifference + Calendar.current.component(.hour, from: Date()) > 24 {
                    Text("+1")
                } else if timeDifference + Calendar.current.component(.hour, from: Date()) < 0 {
                    Text("-1")
                }
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .foregroundColor(.darkGray)
            .background(Color.lightGray)
            .cornerRadius(25)
            Text(cityTime)
        }
        .font(.system(.caption, design: .rounded).weight(.heavy))
        .frame(height: 17)
        .cornerRadius(20)
    }
}


#Preview {
    SettingsCityView(viewModel: CityDataViewModel(), emoji: "🌍", location: "New York", timeDifference: -5)

//    SettingsCityView(emoji: "🌺", location: "Los Angeles, USA", timeDifference: 14, selectedOption: "12hr")
}
