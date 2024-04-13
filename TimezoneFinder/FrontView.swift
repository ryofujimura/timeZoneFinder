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
            HeaderView(titleText: "Front View", flipToBack: flipToBack, iconImage: Image(systemName: "circle"))
        }
    }
}

