//
//  BrowsePhotosAndVideosView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import SwiftUI
import PhotosUI

struct BrowsePhotosAndVideosView: View {
    let accessStatus: PhotoLibraryAccessStatus
    @ObservedObject var uploadDataViewModel: UploadDataViewModel
    @Binding var height: CGFloat
    let minHeight: CGFloat
    
    var body: some View {
        Text("Not what you're looking for? Browse your photo library for that perfect picture.")
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        
        CustomPhotoPickerView(accessStatus: accessStatus, height: $height, minHeight: minHeight, uploadDataViewModel: uploadDataViewModel) {
            Text("Browse Photos")
                .frame(maxWidth: .infinity, alignment: .center)
                .bold()
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                        .frame(width: 150)
                }
        }
    }
}
