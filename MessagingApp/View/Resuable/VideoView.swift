//
//  VideoView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/6/25.
//

import SwiftUI
import AVKit

struct VideoView: View {
    let videoUrls: [String]

    var body: some View {
        VStack(spacing: 20) {
            ForEach(videoUrls.compactMap { URL(string: $0) }, id: \.self) { url in
                VideoMessageThumbnailView(url: url)
            }
        }
    }
}
