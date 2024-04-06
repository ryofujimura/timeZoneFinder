//
//  CityDataModel.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/5/24.
//

import Foundation

class CityDataViewModel: ObservableObject {
    @Published var cityData: [String: CityInfo] = [
        "Los Angeles, USA": CityInfo(timeDifference: -7, emoji: "🌴"),
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
