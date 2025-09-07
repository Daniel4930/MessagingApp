//
//  SelectedFilePreview.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/8/25.
//

import SwiftUI

struct SelectedFilePreview: View {
    let image: UIImage?
    let isFile: Bool
    let index: Int
    @Binding var showPhotoAndFile: Bool
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    let size = CGSize(width: 50, height: 50)
    let cornerRadius: CGFloat = 10
    let cancelButtonSize = CGSize(width: 20, height: 20)
    let cancelButtonBorderWidth: CGFloat = 2
    
    var body: some View {
        Group {
            if isFile {
                Image(systemName: "document.fill")
                    .resizable()
                    .scaledToFit()
            } else if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .foregroundStyle(.white)
        .padding(.top)
        .padding(.trailing)
        .onTapGesture {
            messageComposerViewModel.dataToShow = messageComposerViewModel.selectionData[index]
            showPhotoAndFile.toggle()
        }
        .overlay(alignment: .topTrailing) {
            Button {
                messageComposerViewModel.removeDataAtIndex(index: index)
            } label: {
                Image(systemName: "x.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: cancelButtonSize.width, height: cancelButtonSize.height)
                    .foregroundStyle(Color("ButtonColor"))
                    .bold()
                    .padding(cancelButtonBorderWidth)
                    .background {
                        Circle()
                            .fill(Color.primaryBackground)
                    }
            }
            .offset(x: -cancelButtonSize.width / 2, y: cancelButtonSize.height / 2)
        }
    }
}
