//
//  MessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/11/25.
//

import SwiftUI
import UIKit
import LinkPresentation
import SafariServices

struct MessageView: View {
    let message: Message
    @Binding var updateScrolling: Bool
    let linkRegexPattern = /http(s)?:\/\/(www\.)?.+..+(\/.+)*/
    let linkMetadataService = LinkMetadataService()
    @State private var embededTitle = ""
    @State private var embededDescription = ""
    @State private var embededImage: UIImage?
    @State private var showEmbeded: Bool = false
    @State private var leadingBannerWidth: CGFloat = 0
    @State private var embededImageDimension: (width: CGFloat, height: CGFloat) = (0, 0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let text = message.text {
                if text.contains(linkRegexPattern) {
                    Button {
                        
                    } label: {
                        Text(text)
                            .foregroundStyle(.blue)
                    }
                    .padding(.bottom, 5)
                    .task {
                        retrieveMetaDataFromURL(url: text)
                    }
                    if showEmbeded {
                        organizeEmbededItems()
                            .overlay(alignment: .leading) {
                                Color.gray
                                    .frame(width: leadingBannerWidth)
                            }
                            .background(
                                GeometryReader { proxy in
                                    Color("SecondaryBackgroundColor")
                                        .onAppear {
                                            leadingBannerWidth = proxy.size.width * 0.015
                                        }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                } else {
                    Text(text)
                }
            }
            if !message.imageData.isEmpty {
                GridImageView(imageData: message.imageData)
                    .padding(.top, 5)
            }
        }
    }
}
extension MessageView {
    func retrieveMetaDataFromURL(url: String) {
        linkMetadataService.getMetaDataFromUrl(urlString: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    embededTitle = response.title ?? ""
                    embededDescription = response.description ?? ""
                    embededImage = response.image
                    showEmbeded = true
                    updateScrolling = true
                case .failure(let error):
                    print("Error: Can't retrieve website meta data \(error)")
                }
            }
        }
    }
    @ViewBuilder func organizeEmbededItems() -> some View {
        if embededImageDimension.width > embededImageDimension.height {
            VStack(alignment: .leading) {
                LinkEmbededView(embededTitle: $embededTitle, embededDescription: $embededDescription, embededImage: $embededImage, embededImageDimension: $embededImageDimension)
            }
        } else {
            HStack(alignment: .top) {
                LinkEmbededView(embededTitle: $embededTitle, embededDescription: $embededDescription, embededImage: $embededImage, embededImageDimension: $embededImageDimension)
            }
        }
    }
}

struct GridImageView: View {
    let imageData: [Data?]
    let numImagePerRow = 3
    
    var body: some View {
        let count = imageData.count
        let numRow = ceil(Double(count) / Double(numImagePerRow))
        Grid(horizontalSpacing: 3, verticalSpacing: 3) {
            ForEach(0..<Int(numRow), id: \.self) { row in
                let startIndex = row * numImagePerRow
                let endIndex = min(startIndex + numImagePerRow, count)
                GridRow {
                    ForEach(startIndex..<endIndex, id: \.self) { index in
                        if let data = imageData[index], let uiImage = UIImage(data: data) {
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
}
