//
//  MessageScrollViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/27/25.
//

import SwiftUI

struct MessageScrollViewScrollModifier: ViewModifier {
    @Binding var scrollPosition: ScrollPosition
    let refreshAction: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .scrollPosition($scrollPosition)
            .defaultScrollAnchor(.bottom)
            .refreshable {
                await refreshAction()
            }
    }
}

struct MessageDateViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 13)
    }
}
