//
//  Extensions.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/14/25.
//

import UIKit
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func showKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func applyPadding(_ padding: (edge: Edge.Set, value: CGFloat)?) -> some View {
        if let padding = padding {
            self.padding(padding.edge, padding.value)
        } else {
            self
        }
    }
}

struct KeyboardStateProvider: ViewModifier {
    var updateScrolling: Binding<Bool>
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { notification in
                self.updateScrolling.wrappedValue = true
            }
    }
}

struct KeyboardHeightProvider: ViewModifier {
    var height: Binding<CGFloat>
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                guard let userInfo = notification.userInfo, let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                self.height.wrappedValue = keyboardRect.height
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
                self.height.wrappedValue = 0
            }
    }
}
