//
//  PhotoLibraryViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/2/25.
//

import SwiftUI

struct PhotoLibraryViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollIndicators(.never)
            .font(.subheadline)
            .padding(.horizontal)
    }
}

struct PhotoThumbnailViewModifier: ViewModifier {
    let frame: CGSize
    @Binding var dataExistInSelection: Bool
    let newOpacity: CGFloat = 0.3
    
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: frame.width, height: frame.height)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(dataExistInSelection ? newOpacity : 1)
    }
}

struct VideoThumbnailViewModifier: ViewModifier {
    @Binding var dataExistInSelection: Bool
    let frame: CGSize = .init(width: 120, height: 120)
    let newOpacity: CGFloat = 0.3
    
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: frame.width, height: frame.height)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(dataExistInSelection ? newOpacity : 1)
    }
}
