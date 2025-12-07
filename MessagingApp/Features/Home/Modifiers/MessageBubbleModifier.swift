//
//  MessageBubbleModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/20/25.
//

import SwiftUI

struct MessageBubbleModifier: ViewModifier {
    let buttonAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                Button(action: buttonAction) {
                    Image(systemName: "message.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(.white)
                        .padding()
                        .background {
                            Circle()
                                .fill(.blue)
                        }
                }
                .padding([.trailing, .bottom])
            }
    }
}
