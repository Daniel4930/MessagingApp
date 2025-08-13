//
//  SelectedDataImagePreview.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/8/25.
//

import SwiftUI

struct SelectedDataImagePreview: View {
    let image: UIImage
    let index: Int
    @Binding var showPhotoAndFile: Bool
    @ObservedObject var uploadDataViewModel: UploadDataViewModel
    
    let size = CGSize(width: 50, height: 50)
    let cornerRadius: CGFloat = 10
    let cancelButtonSize = CGSize(width: 20, height: 20)
    let cancelButtonBorderWidth: CGFloat = 2
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(.top)
            .padding(.trailing)
            .onTapGesture {
                uploadDataViewModel.dataToShow = uploadDataViewModel.selectionData[index]
                showPhotoAndFile.toggle()
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    uploadDataViewModel.removeDataAtIndex(index: index)
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
