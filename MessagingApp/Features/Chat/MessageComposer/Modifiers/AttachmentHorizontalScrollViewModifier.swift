//
//  AttachmentHorizontalScrollViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/27/25.
//

import SwiftUI

struct AttachmentPreviewModifier: ViewModifier {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var showAttachment: Bool
    let index: Int
    
    let size = CGSize(width: 50, height: 50)
    let cornerRadius: CGFloat = 10
    let cancelButtonSize = CGSize(width: 20, height: 20)
    let cancelButtonBorderWidth: CGFloat = 2
    
    func body(content: Content) -> some View {
        content
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .foregroundStyle(.white)
            .padding(.top)
            .padding(.trailing)
            .onTapGesture(perform: tapGestureAction)
            .overlay(alignment: .topTrailing) {
                Button(action: removeAttachmentAction) {
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
                .offset(x: cancelButtonWidthOffset, y: cancelButtonHeightOffset)
            }
    }
    
    var cancelButtonWidthOffset: CGFloat {
        -cancelButtonSize.width / 2
    }
    
    var cancelButtonHeightOffset: CGFloat {
        cancelButtonSize.height / 2
    }
    
    func tapGestureAction() {
        messageComposerViewModel.dataToShow = messageComposerViewModel.selectionData[index]
        showAttachment.toggle()
    }
    
    func removeAttachmentAction() {
        messageComposerViewModel.removeDataAtIndex(index: index)
    }
}

struct VideoPlayOverlayModifier: ViewModifier {
    let playImageSize: CGSize
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomLeading) {
                Image(systemName: "play.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: playImageSize.width, height: playImageSize.height)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.secondaryBackground)
                    }
                    .padding([.leading, .bottom], 3)
            }
    }
}
