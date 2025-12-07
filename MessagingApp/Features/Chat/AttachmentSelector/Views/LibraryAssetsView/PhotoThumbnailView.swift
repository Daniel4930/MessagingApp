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
    let frame: CGSize = .init(width: 120, height: 120)
    
    var body: some View {
        contentView
    }
}

// MARK: View components
extension PhotoThumbnailView {
    var contentView: some View {
        Image(uiImage: uiImage)
            .resizable()
            .modifier(PhotoThumbnailViewModifier(frame: frame, dataExistInSelection: $dataExistInSelection))
            .overlay(alignment: .topTrailing) {
                overlayView()
            }
    }
    
    func overlayView() -> some View {
        if dataExistInSelection {
            return AnyView(Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(.blue)
                .padding([.top, .trailing], 8))
        }
        
        return AnyView(EmptyView())
    }
}
