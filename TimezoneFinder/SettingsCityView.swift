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
        HStack{
            Text(emoji)
                .opacity(0.2)
            Text(location)
            Spacer()
            if timeDifference+Calendar.current.component(.hour, from: Date()) > 24 {
                Text("+1")
                    .padding( 5 )
                    .padding(.horizontal, 5)
                    .foregroundColor(.gray)
                    .bold(false)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(25)
                Text(cityTime)
            } else if timeDifference+Calendar.current.component(.hour, from: Date()) < 0 {
                Text("-1")
                    .padding( 5 )
                    .padding(.horizontal, 5)
                    .foregroundColor(.gray)
                    .bold(false)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(25)
                Text(cityTime)
            } else {
                Text(cityTime)
            }
            Text("x")
        }
//        .font(.callout)
        .background(Color.white)
        .bold()
        .foregroundColor(.black)
//        .cornerRadius(20)
        .frame(width: 512-100)
    }
}

#Preview {
    SettingsCityView(emoji: "🌺", location: "Los Angeles, USA", timeDifference: 4)
}
