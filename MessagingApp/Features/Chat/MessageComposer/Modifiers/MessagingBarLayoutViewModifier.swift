//
//  MessagingBarLayoutViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/27/25.
//

import SwiftUI

struct MessagingBarBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color("PrimaryBackgroundColor"))
    }
}

struct MessagingBarOverlayModifier: ViewModifier {
    let overlayOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                overlayContent
            }
    }
    
    @ViewBuilder
    private var overlayContent: some View {
        // This will be replaced by the actual overlay content in the view
        EmptyView()
    }
}

struct MessagingBarInputContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(spacing: 10) {
            content
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
    }
}

struct EditMessageHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tint(.button)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            .padding(.vertical, 10)
            .background(.secondaryBackground)
    }
}

struct MentionSectionModifier: ViewModifier {
    let overlayOffset: CGFloat
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
        }
        .offset(y: overlayOffset)
    }
}