//
//  GridImageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//
import SwiftUI

struct GridImageView: View {
    let imageUrl: [ImageUrl]
    let numImagePerRow = 3
    @State private var showImage = false
    @State private var images: [Image] = []
    @State private var downloadUrl: URL? = nil
    
    let firebaseStorageInstance = FirebaseStorageService.shared
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    var body: some View {
        let count = imageUrl.count
        let numRow = ceil(Double(count) / Double(numImagePerRow))
        Grid(horizontalSpacing: 3, verticalSpacing: 3) {
            ForEach(0..<Int(numRow), id: \.self) { row in
                let startIndex = row * numImagePerRow
                let endIndex = min(startIndex + numImagePerRow, count)
                GridRow {
                    ForEach(startIndex..<endIndex, id: \.self) { index in
                        if let url = imageUrl[index].url {
                            let fileUrl = URL(fileURLWithPath: url.path())
                            
                            Group {
                                if let url = downloadUrl {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .onTapGesture {
                                                    showImage = true
                                                }
                                                .onAppear {
                                                    DispatchQueue.main.async {
                                                        self.images.append(image)
                                                    }
                                                }
                                        }
                                        else if let error = phase.error {
                                            Color.red
                                                .onAppear {
                                                    print(error)
                                                }
                                        } else {
                                            ProgressView()
                                                .frame(width: 120, height: 120)
                                        }
                                    }
                                } else {
                                    ProgressView()
                                        .frame(width: 120, height: 120)
                                }
                            }
                            .onAppear {
                                if downloadUrl == nil {
                                    getDownloadUrlFromFirebase()
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showImage) {
            TabView {
                ForEach(0..<images.count, id: \.self) { index in
                    images[index]
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}

extension GridImageView {
    func getDownloadUrlFromFirebase() {
        let reference = firebaseStorageInstance.createChildReference(folder: .images, fileName: "clyde-icon.png")
        
        firebaseStorageInstance.downloadFileFromBucket(reference: reference) { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self.downloadUrl = url
                }
            case .failure(let error):
                switch error {
                case .downloadError(let errorDescription):
                    print("Failed to download url from firebase: \(errorDescription)")
                case .noUrlError:
                    print("Failed to download url from firebase with error: URL is nil")
                }
            }
        }
    }
}
