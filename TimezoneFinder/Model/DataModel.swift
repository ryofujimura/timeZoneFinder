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
            // Saves the time format to UserDefaults when changed
            UserDefaults.standard.set(timeFormat, forKey: "timeFormat")
        }
    }
    @Published var cityData: [String: CityInfo] = [:] {
        didSet {
            // Saves the city data to UserDefaults when it is updated
            saveCityData()
        }
    }

    init() {
        // Loads city data and time format from UserDefaults during initialization
        loadCityData()
        loadTimeFormat()
    }

    func saveCityData() {
        // Encodes and saves cityData to UserDefaults
        if let encoded = try? JSONEncoder().encode(cityData) {
            UserDefaults.standard.set(encoded, forKey: "cityData")
        }
    }

    func loadCityData() {
        // Loads and decodes city data from UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: "cityData"),
           let decodedData = try? JSONDecoder().decode([String: CityInfo].self, from: savedData) {
            cityData = decodedData
        }
    }

    func loadTimeFormat() {
        // Loads the time format setting from UserDefaults, defaulting to "12hr" if not found
        timeFormat = UserDefaults.standard.string(forKey: "timeFormat") ?? "12hr"
    }
}

struct CityInfo: Codable {
    var timeDifference: Int
    var emoji: String
}

//Global colors
extension Color {
    static let offblack = Color(red: 16/256, green: 16/256, blue: 16/256)
    static let darkGray = Color(red: 132/256, green: 132/256, blue: 132/256)
    static let lightGray = Color(red: 245/256, green: 245/256, blue: 245/256)
    static let offwhite = Color(red: 255/256, green: 255/256, blue: 255/256)
}
