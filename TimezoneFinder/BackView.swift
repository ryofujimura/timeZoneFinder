//
//  BackView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import SwiftUI

struct BackView: View {
    var flipToFront: () -> Void

    var body: some View {
        VStack {
            Text("Back View")
                .font(.largeTitle)
                .padding()
            Button("Return to Front View") {
                flipToFront()
            }
        }
    }
}
