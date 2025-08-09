//
//  PhotosAndVideosGridView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import SwiftUI
import Photos
import PhotosUI

struct PhotosAndVideosGridView: View {
    @Binding var assets: [PHAsset]
    let refreshAssets: () -> Void
    @ObservedObject var uploadDataViewModel: UploadDataViewModel
    
    @State private var openCamera = false
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
                    CameraView(refreshAssets: refreshAssets)
                }
            
            ForEach(assets, id: \.localIdentifier) { asset in
                PhotoThumbnailView(asset: asset, uploadDataViewModel: uploadDataViewModel)
            }
        }
        .padding(.vertical)
    }
}
