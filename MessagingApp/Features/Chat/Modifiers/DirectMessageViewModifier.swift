//
//  DirectMessageViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/22/25.
//

import SwiftUI

struct DirectMessageToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct DirectMessageAnimationModifier: ViewModifier {
    let selectorViewYOffset: CGFloat
    let bottomPaddingForSelector: CGFloat
    @Binding var backgroundOpacity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .animation(.spring(duration: 0.3), value: selectorViewYOffset)
            .animation(.spring(duration: 0.3), value: bottomPaddingForSelector)
            .animation(.spring(duration: 0.3), value: backgroundOpacity)
    }
}

struct DirectMessageOverlayModifier: ViewModifier {
    let selectorHeight: CGFloat
    let backgroundOpacity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if selectorHeight > SelectorView.threshold {
                    Color.black
                        .opacity(backgroundOpacity)
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
    }
}

struct DirectMessagePaddingModifier: ViewModifier {
    let bottomPaddingForSelector: CGFloat
    let safeAreaInsetBottom: CGFloat
    let keyboardWillAppear: Bool
    let showFileAndImageSelector: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, paddingValue)
    }
    
    var paddingValue: CGFloat {
        if keyboardWillAppear || showFileAndImageSelector {
            return bottomPaddingForSelector - safeAreaInsetBottom
        }
        return bottomPaddingForSelector
    }
}
