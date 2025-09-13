//
//  PhotoThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/9/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct PhotoThumbnailView: View {
    let uiImage: UIImage
    @Binding var dataExistInSelection: Bool
    let frame: (width: CGFloat, height: CGFloat) = (120, 120)
    let newOpacity: CGFloat = 0.3
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: frame.width, height: frame.height)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(dataExistInSelection ? newOpacity : 1)
            .overlay(alignment: .topTrailing) {
                if dataExistInSelection {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.blue)
                        .padding([.top, .trailing], 8)
                }
            }
    }
}
