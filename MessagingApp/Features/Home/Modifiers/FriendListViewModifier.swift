//
//  FriendListViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/20/25.
//

import SwiftUI

struct FriendListToolbarModifier: ViewModifier {
    let dismissAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismissAction()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Message")
                        .font(.title3.bold())
                }
            }
    }
}

struct ListButtonModifier: ViewModifier {
    let backgroundColor: Color
    let listItemWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .tint(.white)
            .frame(width: listItemWidth)
            .padding()
            .background(backgroundColor)
            .clipShape(Circle())
    }
}