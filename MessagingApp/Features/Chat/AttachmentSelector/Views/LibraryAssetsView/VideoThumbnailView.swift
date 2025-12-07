//
//  VideoThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/14/25.
//

import SwiftUI
import AVFoundation

struct VideoThumbnailView: View {
    let uiImage: UIImage
    let duration: Double
    @Binding var dataExistInSelection: Bool
    
    var body: some View {
        contentView
    }
}

// MARK: View computed properties
extension VideoThumbnailView {
    var formattedTime: String {
        let durationSeconds = Int(duration)
        
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        let secs = durationSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// MARK: View components
extension VideoThumbnailView {
    var contentView: some View {
        Image(uiImage: uiImage)
            .resizable()
            .modifier(VideoThumbnailViewModifier(dataExistInSelection: $dataExistInSelection))
            .overlay(alignment: .bottomLeading) {
                videoDurationView
            }
            .overlay(alignment: .topTrailing) {
                checkMarkView()
            }

    }
    
    func checkMarkView() -> some View {
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
    
    var videoDurationView: some View {
        HStack {
            Image(systemName: "play.circle.fill")
            Text("\(formattedTime)")
        }
        .font(.caption)
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("SecondaryBackgroundColor"))
        }
        .padding([.leading, .bottom], 5)
    }
}
