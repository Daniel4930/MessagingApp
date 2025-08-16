//
//  VideoThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/14/25.
//

import SwiftUI
import AVFoundation

struct VideoThumbnailView: View {
    let videoUrl: URL
    @Binding var dataExistInSelection: Bool
    
    @State private var duration: Double = .zero
    let frame: (width: CGFloat, height: CGFloat) = (120, 120)
    let newOpacity: CGFloat = 0.3
    
    var body: some View {
        AsyncImage(url: videoUrl) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: frame.width, height: frame.height)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(alignment: .bottomLeading) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("\(formatTime(seconds: Int(duration)))")
                        }
                        .font(.caption)
                        .padding(5)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("SecondaryBackgroundColor"))
                        }
                        .padding([.leading, .bottom], 5)
                    }
                    .opacity(dataExistInSelection ? newOpacity : 1)
                    .overlay(alignment: .topTrailing) {
                        if dataExistInSelection {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
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
    }
}

extension VideoThumbnailView {
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    func getVideoMetadata(url: URL) {
        Task {
            do {
                let asset = AVURLAsset(url: videoUrl)
                for format in try await asset.load(.availableMetadataFormats) {
                    let metadata = try await asset.loadMetadata(for: format)
                    for item in metadata {
                        DispatchQueue.main.async {
                            self.duration = item.duration.seconds
                        }
                    }
                }
                
            } catch {
                
            }
        }
    }
}
