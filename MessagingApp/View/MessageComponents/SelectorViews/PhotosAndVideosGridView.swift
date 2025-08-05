//
//  PhotosAndVideosGridView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import SwiftUI
import Photos

struct PhotosAndVideosGridView: View {
    @Binding var openCamera: Bool
    @Binding var assets: [PHAsset]
    @Binding var selectedPhotosAndFiles: [(image: UIImage?, file: Data?)]
    
    let gridColums = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: gridColums) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.buttonBackground)
                .frame(width: 120, height: 120)
                .overlay {
                    Image(systemName: "camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .onTapGesture {
                    openCamera.toggle()
                }
                .fullScreenCover(isPresented: $openCamera) {
                    ImagePickerView()
                }
            
            ForEach(assets, id: \.localIdentifier) { asset in
                //TODO: change item to accept UIImage instead of PhotoPickerItem
                
                PhotoThumbnailView(asset: asset, item: nil, selectedPhotosAndFiles: $selectedPhotosAndFiles)
            }
        }
        .padding(.vertical)
    }
}
