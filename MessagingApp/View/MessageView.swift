//
//  MessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/11/25.
//

import SwiftUI
import UIKit

struct MessageView: View {
    let message: Message
    @Binding var updateScrolling: Bool
    let linkRegexPattern = /http(s)?:\/\/(www\.)?.+..+(\/.+)*/
    let linkMetadataService = LinkMetadataService()
    @State private var embededTitle = ""
    @State private var embededDescription = ""
    @State private var embededImage: UIImage?
    @State private var showEmbeded: Bool = false
    @State private var showSafari: Bool = false
    @State private var embededImageDimension: (width: CGFloat, height: CGFloat) = (0, 0)
    @State private var linkEmbededViewDimension: (width: CGFloat, height: CGFloat) = (0, 0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let text = message.text {
                if text.contains(linkRegexPattern) {
                    Button {
                        showSafari = true
                    } label: {
                        Text(text)
                            .foregroundStyle(.blue)
                    }
                    .padding(.bottom, 5)
                    .sheet(isPresented: $showSafari) {
                        if let url = URL(string: text) {
                            SafariView(url: url)
                        }
                    }
                    .task {
                        retrieveMetaDataFromURL(url: text)
                    }
                    
                    if showEmbeded {
                        organizeEmbededItems()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .overlay(alignment: .leading) {
                                Color.gray
                                    .frame(width: linkEmbededViewDimension.width * 0.015)
                            }
                            .background(
                                GeometryReader { proxy in
                                    Color("SecondaryBackgroundColor")
                                        .onAppear {
                                            linkEmbededViewDimension.width = proxy.size.width
                                            linkEmbededViewDimension.height = proxy.size.height
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
            if !message.fileData.isEmpty {
                ForEach(Array(message.fileData.enumerated()), id: \.offset) { element in
                    let file = element.element
                    FileEmbededView(name: file.name, data: file.data)
                }
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
                LinkEmbededView(embededTitle: $embededTitle, embededDescription: $embededDescription, embededImage: $embededImage, embededImageDimension: $embededImageDimension, linkEmbededViewDimension: $linkEmbededViewDimension)
            }
        } else {
            HStack(alignment: .center) {
                LinkEmbededView(embededTitle: $embededTitle, embededDescription: $embededDescription, embededImage: $embededImage, embededImageDimension: $embededImageDimension, linkEmbededViewDimension: $linkEmbededViewDimension)
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
