//
//  ChangeAvatarView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/4/25.
//

import SwiftUI
import PhotosUI

struct ChangeAvatarView: View {
    @Binding var avatarPhotoPickerItem: [PhotosPickerItem]
    @Binding var avatarImage: Image?
    @Binding var removeAvatar: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            LineIndicator()
                .padding(.top, 5)
            
            Text("Avatar")
                .font(.title3.bold())
                .padding(.top, 8)
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 0) {
                PhotosPicker(selection: $avatarPhotoPickerItem,
                             maxSelectionCount: 1,
                             matching: .any(of: [.images, .screenshots])) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Upload Image")
                            .bold()
                        Text("Upload image requirement")
                            .font(.footnote)
                            .opacity(0.7)
                    }
                    .foregroundStyle(.white)
                    .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.secondaryBackground.opacity(0.8))
                .modifier(TapGestureAnimation())
                
                DividerView()
                
                Button {
                    avatarPhotoPickerItem = []
                    avatarImage = nil
                    removeAvatar = true
                    dismiss()
                } label: {
                    Text("Remove Avatar")
                        .bold()
                        .foregroundStyle(.red)
                        .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.secondaryBackground.opacity(0.8))
                .modifier(TapGestureAnimation())
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.primaryBackground)
    }
}