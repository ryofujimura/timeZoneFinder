//
//  ContentView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/25/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = CityDataViewModel()
    
    var body: some View {
        MainNavigationView()
            .preferredColorScheme(.light)
            .onAppear(){
                viewModel.settingsView = false
            }
    }
}


#Preview {
    ContentView()
}
