//
//  UserIconView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/16/25.
//
import SwiftUI
import Kingfisher

struct UserIconView: View {
    let urlString: String
    let iconDimension: CGSize
    let borderColor: Color
    let borderWidth: CGFloat
    
    @State private var didFail = false
    
    init(urlString: String?, iconDimension: CGSize = CGSize(width: 37, height: 37), borderColor: Color = .buttonBackground, borderWidth: CGFloat = 2) {
        self.urlString = urlString ?? ""
        self.iconDimension = iconDimension
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    var body: some View {
        if didFail {
            Image(systemName: "person.circle")
                .iconStyle(iconDimension, borderColor: borderColor, borderWidth: borderWidth)
        } else {
            KFImage(URL(string: urlString))
                .placeholder {
                    ProgressView()
                        .frame(width: iconDimension.width, height: iconDimension.height)
                        .clipShape(.circle)
                }
                .onFailure { _ in
                    didFail = true
                }
                .resizable()
                .iconStyle(iconDimension, borderColor: borderColor, borderWidth: borderWidth)
        }
    }
}
