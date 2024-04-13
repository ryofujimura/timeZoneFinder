//
//  FrontView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import SwiftUI

struct FrontView: View {
    var flipToBack: () -> Void

    var body: some View {
        VStack {
            Text("Front View")
                .font(.largeTitle)
                .padding()
            Button("Go to Back View") {
                flipToBack()
            }
        }
    }
}
