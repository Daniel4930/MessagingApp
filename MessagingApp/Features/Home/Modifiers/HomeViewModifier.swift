//
//  HomeViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/20/25.
//

import SwiftUI

struct HomeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: 20, topTrailing: 20)
                )
                .fill(Color.secondaryBackground)
                .opacity(0.5)
            }
    }
}

