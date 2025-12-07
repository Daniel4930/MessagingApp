//
//  NavigationTopBarViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/27/25.
//

import SwiftUI

struct NavigationTopBarBackButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 25, height: 20)
            .tint(.white)
    }
}

struct NavigationTopBarUserInfoModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .bold()
    }
}

struct NavigationTopBarChevronModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 5, height: 10)
            .bold()
    }
}
