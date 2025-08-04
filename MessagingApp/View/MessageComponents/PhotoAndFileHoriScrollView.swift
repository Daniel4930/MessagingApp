//
//  PhotoAndFileHorizontalScrollView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/28/25.
//

import SwiftUI

struct PhotoAndFileHoriScrollView: View {
    @Binding var selectedPhotosAndFiles: [(image: UIImage?, file: Data?)]
    @Binding var showPhotoAndFile: Bool
    
    var body: some View {
        ScrollView([.horizontal]) {
            HStack {
                ForEach(Array(selectedPhotosAndFiles.enumerated()), id: \.offset) { index, element in
                    if let uiImage = element.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.top, 14)
                            .padding(.trailing, 8)
                            .onTapGesture {
                                showPhotoAndFile.toggle()
                            }
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    selectedPhotosAndFiles.remove(at: index)
                                } label: {
                                    Text("x")
                                        .bold()
                                        .foregroundStyle(.black)
                                        .padding(4)
                                        .background {
                                            Circle()
                                                .fill(Color("ButtonColor"))
                                        }
                                }
                            }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
