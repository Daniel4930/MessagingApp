//
//  MentionLayoutAnimationView.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/2/25.
//

import SwiftUI

struct MentionLayoutAnimationView<Content: View>: View {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var currentOffsetOverlay: CGFloat
    let content: Content
    let numUsersToShow: Int
    
    let maxDisplayUsers: CGFloat = 5
    let maxHeight: CGFloat = 300
    let springStiffness = 0.5
    let springDrag = 0.75
    
    init(messageComposerViewModel: MessageComposerViewModel, currentOffsetOverlay: Binding<CGFloat>, content: () -> Content) {
        self.messageComposerViewModel = messageComposerViewModel
        self.content = content()
        self._currentOffsetOverlay = currentOffsetOverlay
        self.numUsersToShow = messageComposerViewModel.mathchUsers.count
    }
    
    var body: some View {
        content
            .modifier(MentionAnimationViewModifier(
                currentOffsetOverlay: $currentOffsetOverlay,
                numUsersToShow: numUsersToShow,
                messageComposerViewModel: messageComposerViewModel)
            )
    }
}
