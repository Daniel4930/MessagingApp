//
//  GridImageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//
import SwiftUI
import Kingfisher

struct GridImageView: View {
    let imageUrl: [String]
    let numImagePerRow = 3
    @State private var showImage = false
    
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

                        KFImage(photoUrl)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onTapGesture {
                                showImage = true
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $showImage) {
            TabView {
                ForEach(0..<imageUrl.count, id: \.self) { index in
                    let photoUrl = URL(string: imageUrl[index])
                    KFImage(photoUrl)
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
