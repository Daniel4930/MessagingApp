//
//  MentionViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/2/25.
//

import SwiftUI

struct MentionButtonViewModifier: ViewModifier {
    @Binding var isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(isPressed ? Color("ButtonClickedBackgroundColor") : Color("SecondaryBackgroundColor"))
            .tint(.white)
    }
}

struct MentionAnimationViewModifier: ViewModifier {
    @Binding var currentOffsetOverlay: CGFloat
    let numUsersToShow: Int
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    let maxDisplayUsers: CGFloat = 5
    let maxHeight: CGFloat = 300
    let springStiffness = 0.5
    let springDrag = 0.75
    
    func body(content: Content) -> some View {
        content
            .frame(height: currentOffsetOverlay)
            .animation(.interactiveSpring(response: springStiffness, dampingFraction: springDrag), value: currentOffsetOverlay)
            .onChange(of: numUsersToShow) { _, newValue in
                onChangeNumUserAction(numUser: newValue)
            }
            .onChange(of: messageComposerViewModel.showMention) { _, newValue in
                onChangeShowMentionAction(showMention: newValue)
            }
    }
    
    func onChangeNumUserAction(numUser: Int) {
        let targetHeight = CGFloat((maxHeight / maxDisplayUsers)) * CGFloat(numUser)
        
        if numUser >= 5 {
            currentOffsetOverlay = maxHeight
            return
        }
        currentOffsetOverlay = targetHeight
    }
    
    func onChangeShowMentionAction(showMention: Bool) {
        if showMention == false {
            currentOffsetOverlay = 0
        }
    }
}
