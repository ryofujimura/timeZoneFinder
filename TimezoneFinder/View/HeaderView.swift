//
//  ViewModel.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//
import Foundation
import SwiftUI

struct HeaderView: View {
    var titleText: String
    var flipTo: () -> Void
    var iconImage: Image
    
    //HeaderView: Header part of view. Includes Title and button to flip between front view and back view
    var body: some View {
        HStack{
            Text(titleText)
                .font(.system(.body, design: .rounded).weight(.heavy))
                .foregroundColor(.offblack)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            Spacer()
            iconImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .font(.system(size: 16, design: .rounded).weight(.bold))
                .padding(.trailing, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    flipTo()
                }
        }
        .foregroundColor(.offblack)
    }
}
