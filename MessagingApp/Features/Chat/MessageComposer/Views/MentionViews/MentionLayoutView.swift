//
//  MentionLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/16/25.
//
import SwiftUI

struct MentionLayoutView: View {
    let users: [User]
    let appendNameToText: (String) -> Void
    @State private var buttonClicked = false
    
    var body: some View {
        mentionContentView
    }
}

// MARK: View components
extension MentionLayoutView {
    var mentionContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(users) { user in
                    MentionButtonView(user: user, onSelect: mentionButtonAction)
                    
                    addDividerView(user: user)
                }
            }
        }
        .background(Color("SecondaryBackgroundColor"))
    }
    
    func addDividerView(user: User) -> some View {
        if let lastUser = users.last, lastUser.id != user.id {
            return AnyView(DividerView(padding: (Edge.Set.horizontal, 16)))
        }
        return AnyView(EmptyView())
    }
}

// MARK: View actions
extension MentionLayoutView {
    func mentionButtonAction(name: String) {
        appendNameToText(name)
    }
}
