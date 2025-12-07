//
//  UploadedFileInfoViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/29/25.
//

import SwiftUI

struct FileInfoModifier: ViewModifier {
    let thumbnailSize: CGSize
    
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            .padding(.vertical)
            .background(Color.primaryBackground)
    }
}

struct RemoveFileButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .bold()
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 20)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.buttonBackground)
            }
    }
}

struct UploadedFileInfoContentViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryBackground)
    }
}
