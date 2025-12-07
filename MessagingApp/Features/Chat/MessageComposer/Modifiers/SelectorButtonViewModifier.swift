//
//  SelectorButtonViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/29/25.
//

import SwiftUI

struct SelectorButtonViewModifier: ViewModifier {
    @Binding var showSelector: Bool
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (23, 23)
    let animationDuration: Double = 0.3
    let rotationAngle: Double = 45.0
    let paddingSpace: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(showSelector ? rotationAngle : 0))
            .frame(width: iconDimension.width, height: iconDimension.height)
            .padding(paddingSpace)
            .background(Color("SecondaryBackgroundColor"))
            .clipShape(.circle)
            .foregroundStyle(showSelector ? .blue : .white)
            .animation(.spring(duration: animationDuration, bounce: 0), value: showSelector)
    }
}
