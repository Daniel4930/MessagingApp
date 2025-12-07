//
//  NotificationViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/20/25.
//

import SwiftUI

struct NotificationHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title2.bold())
            .padding()
            .overlay(alignment: .bottom) {
                DividerView()
            }
    }
}

struct NotificationCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray)
                    .brightness(-0.4)
            )
            .padding(.bottom)
    }
}

struct NotificationButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
    }
}