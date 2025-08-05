//
//  BrowsePhotosAndVideosView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import SwiftUI
import PhotosUI

struct BrowsePhotosAndVideosView: View {
    @Binding var photoPickerItems: [PhotosPickerItem]
    
    var body: some View {
        Text("Not what you're looking for? Browse your photo library for that perfect picture.")
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        
        PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 10) {
            Text("Browse Photos")
                .bold()
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                        .frame(width: 150)
                }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
