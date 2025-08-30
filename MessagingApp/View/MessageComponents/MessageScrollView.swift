//
//  MessageScrollView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import SwiftUI

struct MessageScrollView: View {
    let channelInfo: Channel
    @Binding var scrollToBottom: Bool
    @FocusState.Binding var focusedField: Field?
    @State private var scrollPosition = ScrollPosition()
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    
    var body: some View {
        let dayGroups = messageViewModel.groupedMessages(for: channelInfo.id!)
        
        ScrollView {
            LazyVStack(alignment: .leading) {
                if dayGroups.isEmpty {
                    EmptyMessageView()
                } else {
                    ForEach(dayGroups, id: \.date) { dayGroup in
                        MessageDateView(date: dayGroup.date)
                            .padding(.horizontal, 13)
                        
                        ForEach(dayGroup.messageGroups, id: \.time) { messageGroup in
                            ForEach(messageGroup.userGroups, id: \.userId) { userGroup in
                                if let user = friendViewModel.getUser(withId: userGroup.userId, currentUser: userViewModel.user) {
                                    MessageLayoutView(user: user, messages: userGroup.messages, time: messageGroup.time)
                                }
                            }
                        }
                    }
                }
            }
        }
        .scrollPosition($scrollPosition)
        .scrollDismissesKeyboard(.immediately)
        .defaultScrollAnchor(.bottom)
        .onScrollPhaseChange { oldPhase, newPhase in
            if newPhase == .interacting {
                focusedField = nil
            }
        }
        .onChange(of: scrollToBottom) { _, newValue in
            if newValue == true {
                withAnimation(.spring(duration: 0.2)) {
                    scrollPosition.scrollTo(edge: .bottom)
                }
                scrollToBottom = false
            }
        }
        .task {
            // When the view appears, find all other members in the channel and fetch their info if needed.
            guard let currentUserId = userViewModel.user?.id else { return }
            
            let otherMemberIds = channelInfo.memberIds.filter { $0 != currentUserId }
            
            for memberId in otherMemberIds {
                await friendViewModel.fetchUserIfNeeded(withId: memberId)
            }
        }
    }
}

struct EmptyMessageView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("This is the beginning of your conversion")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.trailing)
            Image(systemName: "message.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }
}
