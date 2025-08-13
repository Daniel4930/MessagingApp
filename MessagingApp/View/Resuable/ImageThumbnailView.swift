//
//  ImageThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/9/25.
//

import SwiftUI

struct ImageThumbnailView: View {
    let uiImage: UIImage
    let frame: (width: CGFloat, height: CGFloat) = (120, 120)
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: frame.width, height: frame.height)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
