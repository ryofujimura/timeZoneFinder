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
            HeaderView(titleText: "Back View", flipTo: flipToFront, iconImage: Image(systemName: "circle.fill"))
        }
    }
}
