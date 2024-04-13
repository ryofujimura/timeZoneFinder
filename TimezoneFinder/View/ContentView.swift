//
//  ContentView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/25/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showingBack = false
    @StateObject var viewModel = DataModel()

    var body: some View {
        Group{
            if showingBack {
                BackView(flipToFront: { showingBack = false }, viewModel: viewModel)
            } else {
                FrontView(flipToBack: { showingBack = true }, viewModel: viewModel)
            }
        }
        .padding(12)
        .frame(width: 416)
        .preferredColorScheme(.light)
        
    }

    func resetView() {
        showingBack = false
    }
}
