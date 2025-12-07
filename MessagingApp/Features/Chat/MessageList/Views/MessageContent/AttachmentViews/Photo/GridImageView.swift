//
//  GridImageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//

import SwiftUI

struct GridImageView: View {
    let imageUrls: [String]?
    let selectedImages: [SelectedAttachment]?
    let dimensions: [MediaDimension]?

    static let numImagePerRow = 3
    @State private var showImage = false
    @State private var selectedIndex = 0
    
    var body: some View {
        if let selectedImages, !selectedImages.isEmpty {
            if !photoAttachments.isEmpty {
                photoAttachmentGridView(
                    count: photoAttachments.count,
                    attachmentView: photoAttachmentView(index:),
                    sheetContent: photoAttachmentTabViewContent(index:)
                )
            }
        } else {
            if let imageUrls, !imageUrls.isEmpty {
                photoAttachmentGridView(
                    count: imageUrls.count,
                    attachmentView: urlImageAttachmentView(index:),
                    sheetContent: urlImageAttachmentTabViewContent(index:)
                )
            }
        }
    }
}

// MARK: - View components
extension GridImageView {
    func buildGrid<Content: View>(count: Int, @ViewBuilder content: @escaping (Int) -> Content) -> some View {
        let numRow = ceil(Double(count) / Double(GridImageView.numImagePerRow))
        return Grid(horizontalSpacing: 3, verticalSpacing: 3) {
            ForEach(0..<Int(numRow), id: \.self) { row in
                let startIndex = row * GridImageView.numImagePerRow
                let endIndex = min(startIndex + GridImageView.numImagePerRow, count)
                GridRow {
                    ForEach(startIndex..<endIndex, id: \.self) { index in
                        content(index)
                    }
                }
            }
        }
    }
    
    func photoAttachmentGridView(
        count: Int,
        attachmentView: @escaping (Int) -> some View,
        sheetContent: @escaping (Int) -> some View
    ) -> some View {
        buildGrid(count: count) { index in
            attachmentView(index)
        }
        .modifier(ImageGridSheetModifier(
            isPresented: $showImage,
            selectedIndex: $selectedIndex,
            count: count,
            content: sheetContent
        ))
    }
    
    @ViewBuilder func photoAttachmentView(index: Int) -> some View {
        if let uiImage = photoAttachments[index].image {
            PendingAttachmentsView(attachmentId: photoAttachments[index].id) {
                ImageAttachmentView(uiImage: uiImage)
            }
            .onTapGesture { photoAttachmentTapAction(index: index) }
        }
    }
    
    @ViewBuilder func photoAttachmentTabViewContent(index: Int) -> some View {
        if let uiImage = photoAttachments[index].image {
            ImageAttachmentView(uiImage: uiImage)
        }
    }
    
    @ViewBuilder func urlImageAttachmentView(index: Int) -> some View {
        let url = URL(string: imageUrls![index])
        let dimension = dimensions?[safe: index]
        let size = CGSize(width: dimension?.width ?? .zero, height: dimension?.height ?? .zero)

        KFImageView(url: url, dimension: dimension, size: size)
            .onTapGesture { photoAttachmentTapAction(index: index) }
    }
    
    @ViewBuilder func urlImageAttachmentTabViewContent(index: Int) -> some View {
        let url = URL(string: imageUrls![index])
        let dimension = dimensions?[safe: index]
        let size = CGSize(width: dimension?.width ?? .zero, height: dimension?.height ?? .zero)
        
        KFImageView(url: url, dimension: dimension, size: size)
    }
}

// MARK: - View properties
extension GridImageView {
    var photoAttachments: [SelectedAttachment] {
        guard let selectedImages else {
            return []
        }
        return selectedImages.filter { $0.attachmentType == .photo }
    }
}

// MARK: - View actions
extension GridImageView {
    func photoAttachmentTapAction(index: Int) {
        selectedIndex = index
        showImage = true
    }
}
