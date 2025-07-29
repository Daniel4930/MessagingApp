//
//  PhotoThumbnailView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/26/25.
//

import SwiftUI
import PhotosUI

struct PhotoThumbnailView: View {
    let item: PhotosPickerItem
    @Binding var selectedPhotosAndFiles: [(image: UIImage?, file: Data?)]
    @State private var image: UIImage? = nil
    
    let frame: (width: CGFloat, height: CGFloat) = (120, 120)
    
    var body: some View {
        ZStack {
            if let image {
                Button {
                    selectedPhotosAndFiles.append((image: image, file: nil))
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: frame.width, height: frame.height)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: frame.width, height: frame.height)
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    func loadImage() {
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    image = uiImage
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
