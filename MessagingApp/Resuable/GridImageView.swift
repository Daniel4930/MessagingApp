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
        if let selectedImages, !selectedImages.isEmpty {
            let photoAttachments = selectedImages.filter { $0.attachmentType == .photo }
            if !photoAttachments.isEmpty {
                let count = photoAttachments.count
                buildGrid(count: count) { index in
                    if let uiImage = photoAttachments[index].image {
                        PendingAttachmentsView(attachmentId: photoAttachments[index].id) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .onTapGesture {
                            selectedIndex = index
                            showImage = true
                        }
                    }
                }
                .modifier(ImageGridSheetModifier(
                    isPresented: $showImage,
                    selectedIndex: $selectedIndex,
                    count: count,
                    content: { index in
                        if let uiImage = photoAttachments[index].image {
                            return AnyView(
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            )
                        } else {
                            return AnyView(EmptyView())
                        }
                    }
                ))
            }
        } else {
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
                .modifier(ImageGridSheetModifier(
                    isPresented: $showImage,
                    selectedIndex: $selectedIndex,
                    count: count,
                    content: { index in
                        let url = URL(string: imageUrls[index])
                        return AnyView(
                            KFImage(url)
                                .cacheMemoryOnly()
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                    }
                ))
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

// MARK: - Sheet Modifier
struct ImageGridSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedIndex: Int
    let count: Int
    let content: (Int) -> AnyView

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                TabView(selection: $selectedIndex) {
                    ForEach(0..<count, id: \.self) { index in
                        self.content(index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
            }
    }
}
