//
//  GridImageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//
import SwiftUI

struct GridImageView: View {
    let imageUrl: [String]
    let numImagePerRow = 3
    @State private var showImage = false
    @State private var images: [Image] = []
    
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
                        let photoUrl = URL(string: imageUrl[index])

                        AsyncImage(url: photoUrl) { phase in
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
