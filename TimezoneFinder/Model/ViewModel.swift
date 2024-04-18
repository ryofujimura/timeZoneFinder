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
    
    var body: some View {
        HStack{
            Text(titleText)
//                .font(.system(size: 17, weight: .heavy, design: .rounded))
//                .padding(.horizontal, 4)
//                .padding(.vertical, 2)
                .font(.system(.body, design: .rounded).weight(.heavy))
                .foregroundColor(.offblack)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            Spacer()
            iconImage
                .resizable()  // Allows the image to be resized
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
