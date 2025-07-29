//
//  SelectorNavTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/27/25.
//

import SwiftUI
import PhotosUI

struct SelectorNavTopBar: View {
    @Binding var height: CGFloat
    let minHeight: CGFloat
    @Binding var photoPickerItems: [PhotosPickerItem]
    
    var body: some View {
        HStack(alignment: .center) {
            Button("Back") {
                height = minHeight
            }
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            VStack(spacing: 0) {
                Text(photoPickerItems.isEmpty ? "Recents" : "\(photoPickerItems.count) selected")
                    .bold()
                    .font(.title2)
                Text("Select up to 10")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 10) {
                Text("All Albums")
                    .padding(14)
                    .foregroundStyle(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
