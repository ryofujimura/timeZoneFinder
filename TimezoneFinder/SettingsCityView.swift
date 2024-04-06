//
//  SettingsCityView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/2/24.
//

import SwiftUI

struct SettingsCityView: View {
    var emoji: String
    var location: String
    var timeDifference: Int
    var cityTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        // Calculate the date and time with the time difference
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
//                    .padding(.vertical, 1.5)
            Spacer()
            Group{
                if timeDifference+Calendar.current.component(.hour, from: Date()) > 24 {
                    Text("+1")
                } else if timeDifference+Calendar.current.component(.hour, from: Date()) < 0 {
                    Text("-1")
                }
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .foregroundColor(.gray)
            .background(Color.black.opacity(0.05))
            .cornerRadius(25)
            Text(cityTime)
        }
        .font(.system(.caption, design: .rounded).weight(.heavy))
        .frame(height: 17)
//        .background(Color.white)
        .cornerRadius(20)
    }
}

#Preview {
    SettingsCityView(emoji: "🌺", location: "Los Angeles, USA", timeDifference: 14)
}
