//
//  KFImageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/29/25.
//

import SwiftUI
import Kingfisher

struct KFImageView: View {
    let url: URL?
    let dimension: MediaDimension?
    let size: CGSize
    
    var body: some View {
        KFImage(url)
            .placeholder { progressView(dimension: dimension) }
            .fade(duration: 0.25)
            .cacheMemoryOnly()
            .backgroundDecode()
            .resizable()
            .aspectRatio(size, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - View components
extension KFImageView {
    @ViewBuilder func progressView(dimension: MediaDimension?) -> some View {
        if let dimension {
            Color.gray.opacity(0.1)
                .aspectRatio(CGSize(width: dimension.width, height: dimension.height), contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    ProgressView()
                }
        }
    }
}
