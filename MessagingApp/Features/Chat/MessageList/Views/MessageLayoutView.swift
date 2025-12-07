//
//  UserConversationView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//
import SwiftUI

struct MessageLayoutView: View {
    let user: User
    let messages: [Message]
    let time: Date
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @FocusState.Binding var focusedField: Field?
    let iconDimension: CGSize = .init(width: 45, height: 45)
    
    var body: some View {
        HStack(alignment: .top) {
            UserIconView(urlString: user.icon, iconDimension: iconDimension)
                .onTapGesture(perform: showUserProfile)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    senderName
                    messageDate
                }
                messageContent
            }
            .scrollTargetLayout()
        }
        .padding(.horizontal, 13)
        .padding(.bottom)
    }
}

// MARK: View components
extension MessageLayoutView {
    var senderName: some View {
        Text(user.displayName.isEmpty ? user.userName : user.displayName)
            .font(.title3)
            .bold()
            .onTapGesture(perform: showUserProfile)
    }
    
    var messageDate: some View {
        Text(MessageLayoutView.messageTimeFormatter.string(from: time))
            .font(.footnote)
            .foregroundStyle(.gray)
    }
    
    var messageContent: some View {
        ForEach(messages) { message in
            MessageContentView(
                message: message,
                messageComposerViewModel: messageComposerViewModel,
                focusedField: $focusedField
            )
            .id(message.id)
        }
    }
}

// MARK: View actions
extension MessageLayoutView {
    func showUserProfile() {
        messageComposerViewModel.userProfile = user
    }
    
    static let messageTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy, hh:mm a"
        formatter.timeZone = .current
        return formatter
    }()
}
