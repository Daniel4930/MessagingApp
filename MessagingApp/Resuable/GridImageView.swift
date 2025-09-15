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
        let count = imageUrls?.count ?? selectedImages?.count ?? 0
        
        if let imageUrls {
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
        
        if let selectedImages {
            buildGrid(count: count) { index in
                if selectedImages[index].attachmentType == .photo, let uiImage = selectedImages[index].image {
                    LocalImageView(
                        uiImage: uiImage,
                        uploadTask: selectedImages[index].task,
                        attachmentId: selectedImages[index].id
                    )
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
