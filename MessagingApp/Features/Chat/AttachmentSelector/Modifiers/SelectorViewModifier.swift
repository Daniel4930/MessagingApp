//
//  SelectorViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/3/25.
//

import SwiftUI

struct SelectorViewModifier: ViewModifier {
    let animationTrigger: Bool
    @Binding var selectorHeight: CGFloat
    
    func body(content: Content) -> some View {
        content
            .animation(.smooth(duration: 0.3), value: animationTrigger)
            .foregroundStyle(Color.button)
            .frame(maxWidth: .infinity)
            .frame(height: selectorHeight)
            .background(Color.primaryBackground)
    }
}
