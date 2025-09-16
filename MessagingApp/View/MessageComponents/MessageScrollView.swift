//
//  MessageScrollView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import SwiftUI

struct MessageScrollView: View {
    let channelInfo: Channel
    @FocusState.Binding var focusedField: Field?
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    @State private var scrollPosition = ScrollPosition(idType: String.self)
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var keyboardProvider: KeyboardProvider
    
    var body: some View {
        let messages = messageViewModel.messages.first(where: { $0.channelId == channelInfo.id })?.messages ?? []
        let dayGroups = messageViewModel.groupedMessages(messages: messages)
        
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(dayGroups, id: \.date) { dayGroup in
                    MessageDateView(date: dayGroup.date)
                        .padding(.horizontal, 13)
                    
                    ForEach(dayGroup.messageGroups, id: \.time) { messageGroup in
                        ForEach(messageGroup.userGroups, id: \.userId) { userGroup in
                            if let user = friendViewModel.getUser(withId: userGroup.userId, currentUser: userViewModel.user) {
                                MessageLayoutView(
                                    user: user,
                                    messages: userGroup.messages,
                                    time: messageGroup.time,
                                    messageComposerViewModel: messageComposerViewModel,
                                    focusedField: $focusedField)
                            }
                        }
                    }
                }
            }
        }
        .scrollPosition($scrollPosition)
        .defaultScrollAnchor(.bottom)
        .refreshable {
            guard let channelId = channelInfo.id else { return }
            guard let messageMap = messageViewModel.messages.first(where: { $0.channelId == channelId }) else { return }
            guard let messageId = messageMap.messages.first?.id else { return }
            
            await messageViewModel.fetchMoreMessages(channelId: channelId)
            messageComposerViewModel.scrollToMessageId = messageId
        }
        .onScrollPhaseChange { oldPhase, newPhase, context in
            if let dy = context.velocity?.dy, abs(dy) >= 1.5 {
                focusedField = nil
            }
        }
        .onChange(of: messageComposerViewModel.scrollToBottom) { _, newValue in
            if newValue == true {
                scrollPosition.scrollTo(edge: .bottom)
                messageComposerViewModel.scrollToBottom = false
            }
        }
        .onChange(of: messageComposerViewModel.scrollToMessageId) { oldValue, newValue in
            scrollPosition.scrollTo(id: newValue, anchor: .bottom)
        }
    }
}
