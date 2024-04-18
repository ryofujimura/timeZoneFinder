//
//  FrontView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import SwiftUI

struct FrontView: View {
    var flipToBack: () -> Void
    @ObservedObject var viewModel : DataModel

    
    var body: some View {
        VStack {
            HeaderView(titleText: "Matcha Time", flipTo: flipToBack, iconImage: Image(systemName: "line.3.horizontal"))
            FrontBodyView(viewModel: viewModel)
        }
        .frame(minHeight: 416)
    }
}

#Preview {
    FrontView(flipToBack: { }, viewModel: DataModel())
}
