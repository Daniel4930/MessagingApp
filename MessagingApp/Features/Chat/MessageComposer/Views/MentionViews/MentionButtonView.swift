//
//  MentionButtonView.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/2/25.
//

import SwiftUI

struct MentionButtonView: View {
    let user: User
    let onSelect: (String) -> Void
    @State private var isPressed = false
    
    let animationDuration = 0.1
    let removeMentionViewDeadline = 0.2
    
    var body: some View {
        Button(action: buttonAction) {
            HStack {
                UserIconView(urlString: user.icon)
                
                mentionDisplayName
                
                Spacer()
                
                mentionUserName
            }
            .modifier(MentionButtonViewModifier(isPressed: $isPressed))
        }
    }
}

// MARK: View components
extension MentionButtonView {
    var mentionDisplayName: some View {
        Text(user.displayName.isEmpty ? user.userName : user.displayName)
            .bold()
    }
    
    var mentionUserName: some View {
        Text(user.userName)
            .font(.footnote)
            .foregroundStyle(.gray)
    }
}

// MARK: View actions
extension MentionButtonView {
    func buttonAction() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            isPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + removeMentionViewDeadline) {
            onSelect(user.userName)
        }
    }
}
