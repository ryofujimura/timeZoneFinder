//
//  DataModel.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import Foundation
import SwiftUI

class DataModel: ObservableObject {
    @Published var timeFormat: String = "12hr" {
        didSet {
            UserDefaults.standard.set(timeFormat, forKey: "timeFormat")
        }
    }
    @Published var cityData: [String: CityInfo] = [:] {
        didSet {
            saveCityData()
        }
    }

    init() {
        loadCityData()
        loadTimeFormat()
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

    func loadTimeFormat() {
        timeFormat = UserDefaults.standard.string(forKey: "timeFormat") ?? "12hr"
    }
}

struct CityInfo: Codable {
    var timeDifference: Int
    var emoji: String
}

extension Color {
    static let offblack = Color(red: 16/256, green: 16/256, blue: 16/256)
    static let darkGray = Color(red: 132/256, green: 132/256, blue: 132/256)
    static let lightGray = Color(red: 245/256, green: 245/256, blue: 245/256)
    static let offwhite = Color(red: 255/256, green: 255/256, blue: 255/256)
}
