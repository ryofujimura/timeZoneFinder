//
//  ContentView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/25/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        MainNavigationView()

        CitySearchView()
            .preferredColorScheme(.light)
    }
}


#Preview {
    ContentView()
}
