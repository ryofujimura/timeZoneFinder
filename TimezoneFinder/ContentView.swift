//
//  ContentView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/25/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showingBack = false

    var body: some View {
        if showingBack {
            BackView(flipToFront: { showingBack = false })
        } else {
            FrontView(flipToBack: { showingBack = true })
        }
    }

    func resetView() {
        showingBack = false
    }
}

