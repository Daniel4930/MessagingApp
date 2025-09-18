//
//  GridImageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//

import SwiftUI
import Kingfisher
import FirebaseStorage

struct GridImageView: View {
    let imageUrls: [String]?
    let selectedImages: [SelectedAttachment]?
    
    let numImagePerRow = 3
    @State private var showImage = false
    @State private var selectedIndex = 0
    
    var body: some View {
        if let imageUrls, !imageUrls.isEmpty {
            let count = imageUrls.count
            buildGrid(count: count) { index in
                let url = URL(string: imageUrls[index])
                KFImage(url)
                    .cacheMemoryOnly()
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        selectedIndex = index
                        showImage = true
                    }
            }
            .sheet(isPresented: $showImage) {
                TabView(selection: $selectedIndex) {
                    ForEach(0..<count, id: \.self) { index in
                        let url = URL(string: imageUrls[index])
                        KFImage(url)
                            .cacheMemoryOnly()
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
            }
        }
        
        if let selectedImages, !selectedImages.isEmpty {
            let photoAttachments = selectedImages.filter { $0.attachmentType == .photo }
            if !photoAttachments.isEmpty {
                let count = photoAttachments.count
                buildGrid(count: count) { index in
                    if let uiImage = photoAttachments[index].image {
                        PendingAttachmentsView(task: photoAttachments[index].task, attachmentId: photoAttachments[index].id) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
    }
    
    // Reusable grid builder
    private func buildGrid<Content: View>(count: Int, @ViewBuilder content: @escaping (Int) -> Content) -> some View {
        let numRow = ceil(Double(count) / Double(numImagePerRow))
        return Grid(horizontalSpacing: 3, verticalSpacing: 3) {
            ForEach(0..<Int(numRow), id: \.self) { row in
                let startIndex = row * numImagePerRow
                let endIndex = min(startIndex + numImagePerRow, count)
                GridRow {
                    ForEach(startIndex..<endIndex, id: \.self) { index in
                        content(index)
                    }
                }
            }
        }
    }
}
