//
//  CityDataModel.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/5/24.
//

import Foundation

class CityDataViewModel: ObservableObject {
    @Published var cityData: [String: CityInfo] = [
        "London, UK": CityInfo(timeDifference: 0, emoji: "🎡"),
        "Honolulu, USA": CityInfo(timeDifference: -10, emoji: "🌺"),
        "Los Angeles, USA": CityInfo(timeDifference: -7, emoji: "🌴"),
        "New York, USA": CityInfo(timeDifference: -4, emoji: "🗽")
    ]

    init() {
        loadCityData()
    }

    func saveCityData() {
        if let encoded = try? JSONEncoder().encode(cityData) {
            UserDefaults.standard.set(encoded, forKey: "cityData")
        }
    }

    func loadCityData() {
        if let savedData = UserDefaults.standard.data(forKey: "cityData"),
        let decodedData = try? JSONDecoder().decode([String: CityInfo].self, from: savedData) {
            cityData = decodedData
        }
    }
}
struct CityInfo: Codable {
    var timeDifference: Int
    var emoji: String
}
