//
//  CustomUITextViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/29/25.
//

import SwiftUI

struct CustomUITextViewModifier: ViewModifier {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @FocusState.Binding var focusedField: Field?
    
    let horizontalPaddingSpace: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .frame(height: uiTextViewHeight)
            .padding(.horizontal, horizontalPaddingSpace)
            .focused($focusedField, equals: .textField)
    }
    
    var uiTextViewHeight: CGFloat {
        min(messageComposerViewModel.customTextEditorHeight, MessageComposerViewModel.customTextEditorMaxHeight)
    }
}
