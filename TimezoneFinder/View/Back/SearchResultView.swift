//
//  SearchResultView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import SwiftUI

struct SearchResultView: View {
    @ObservedObject var viewModel : DataModel
    var emoji: String
    var location: String
    var timeDifference: Int
    
    var cityTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = viewModel.timeFormat == "12hr" ? "h:mm a" : "HH:mm"
        formatter.locale = Locale(identifier: "en_US")
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        // For "Your Location", use time difference calculation
        if location == "Your Location" {
            if let adjustedDate = Calendar.current.date(byAdding: .hour, value: timeDifference, to: Date()) {
                return formatter.string(from: adjustedDate)
            } else {
                return "Error"
            }
        }
        
        // For saved cities, use stored timeZoneID if available
        if let cityInfo = viewModel.cityData[location],
           let timeZone = TimeZone(identifier: cityInfo.timeZoneID) {
            formatter.timeZone = timeZone
            return formatter.string(from: Date())
        }
        
        // Fallback to time difference calculation
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
            
            // Get the city info to check for country
            if location != "Your Location", let cityInfo = viewModel.cityData[location] {
                // Use the country if available
                let displayName = cityInfo.country.isEmpty ? location : "\(location), \(cityInfo.country)"
                Text(displayName)
            } else {
                Text(location)
            }
            
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
//        .background(Color.lightGray)
    }
}


#Preview {
    SearchResultView(viewModel: DataModel(), emoji: "🌍", location: "New York", timeDifference: -5)
}
