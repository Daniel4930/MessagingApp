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
            
            avatarTextView
            
            VStack(alignment: .leading, spacing: 0) {
                PhotosPicker(selection: $avatarPhotoPickerItem,
                             maxSelectionCount: 1,
                             matching: .any(of: [.images, .screenshots])) {
                    photoPickerLabelView
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.secondaryBackground.opacity(0.8))
                .modifier(TapGestureAnimation())
                
                DividerView()
                
                removeAvatarButton
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

// MARK: - View components
extension ChangeAvatarView {
    var avatarTextView: some View {
        Text("Avatar")
            .font(.title3.bold())
            .padding(.top, 8)
            .padding(.bottom)
    }
    
    var photoPickerLabelView: some View {
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
    
    var removeAvatarButton: some View {
        Button(action: removeAvatarAction) {
            Text("Remove Avatar")
                .bold()
                .foregroundStyle(.red)
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondaryBackground.opacity(0.8))
        .modifier(TapGestureAnimation())
    }
}

// MARK: - View actions
extension ChangeAvatarView {
    func removeAvatarAction() {
        avatarPhotoPickerItem = []
        avatarImage = nil
        removeAvatar = true
        dismiss()
    }
}
