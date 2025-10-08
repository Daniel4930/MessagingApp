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
    @State private var cachedDayGroups: [MessageViewModel.DayGroup] = []
    @State private var cachedUserLookup: [String: User] = [:]
    @State private var lastMessageCount: Int = 0

    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var keyboardProvider: KeyboardProvider

    var body: some View {
        scrollViewContent
            .scrollPosition($scrollPosition)
            .defaultScrollAnchor(.bottom)
            .refreshable {
                await handleRefresh()
            }
            .onScrollPhaseChange { oldPhase, newPhase, context in
                handleScrollPhaseChange(context: context)
            }
            .onChange(of: messageComposerViewModel.scrollToBottom) { _, newValue in
                handleScrollToBottomChange(newValue)
            }
            .onChange(of: messageComposerViewModel.scrollToMessageId) { oldValue, newValue in
                scrollPosition.scrollTo(id: newValue, anchor: .bottom)
            }
            .onChange(of: messageViewModel.messages) { _, _ in
                updateCachedData()
            }
            .onChange(of: friendViewModel.friends) { _, _ in
                updateUserLookup()
            }
            .onAppear {
                updateCachedData()
            }
    }

    private var scrollViewContent: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(cachedDayGroups, id: \.date) { dayGroup in
                    DayGroupView(
                        dayGroup: dayGroup,
                        cachedUserLookup: cachedUserLookup,
                        messageComposerViewModel: messageComposerViewModel,
                        focusedField: $focusedField
                    )
                }
            }
        }
    }

    private func handleRefresh() async {
        guard let channelId = channelInfo.id else { return }
        guard let messageMap = messageViewModel.messages.first(where: { $0.channelId == channelId }) else { return }
        guard let messageId = messageMap.messages.first?.id else { return }

        await messageViewModel.fetchMoreMessages(channelId: channelId)
        messageComposerViewModel.scrollToMessageId = messageId
    }

    private func handleScrollPhaseChange(context: ScrollPhaseChangeContext) {
        if let dy = context.velocity?.dy, abs(dy) >= 1.5 {
            focusedField = nil
        }
    }

    private func handleScrollToBottomChange(_ newValue: Bool) {
        if newValue == true {
            scrollPosition.scrollTo(edge: .bottom)
            messageComposerViewModel.scrollToBottom = false
        }
    }

    private func updateCachedData() {
        let messages = messageViewModel.messages.first(where: { $0.channelId == channelInfo.id })?.messages ?? []

        // Recompute if message count changed or if cachedDayGroups is empty
        if messages.count != lastMessageCount || cachedDayGroups.isEmpty {
            lastMessageCount = messages.count
            cachedDayGroups = messageViewModel.groupedMessages(messages: messages)
            updateUserLookup()
        }
    }

    private func updateUserLookup() {
        // Ensure we have data to work with
        guard !cachedDayGroups.isEmpty else {
            cachedUserLookup = [:]
            return
        }

        var lookup: [String: User] = [:]

        // Build user lookup dictionary for O(1) access
        for dayGroup in cachedDayGroups {
            for messageGroup in dayGroup.messageGroups {
                for userGroup in messageGroup.userGroups {
                    if lookup[userGroup.userId] == nil {
                        if let user = friendViewModel.getUser(withId: userGroup.userId, currentUser: userViewModel.user) {
                            lookup[userGroup.userId] = user
                        }
                    }
                }
            }
        }

        cachedUserLookup = lookup
    }
}

private struct DayGroupView: View {
    let dayGroup: MessageViewModel.DayGroup
    let cachedUserLookup: [String: User]
    let messageComposerViewModel: MessageComposerViewModel
    @FocusState.Binding var focusedField: Field?

    var body: some View {
        MessageDateView(date: dayGroup.date)
            .padding(.horizontal, 13)

        ForEach(dayGroup.messageGroups, id: \.time) { messageGroup in
            MessageGroupView(
                messageGroup: messageGroup,
                cachedUserLookup: cachedUserLookup,
                messageComposerViewModel: messageComposerViewModel,
                focusedField: $focusedField
            )
        }
    }
}

private struct MessageGroupView: View {
    let messageGroup: MessageViewModel.MessageGroup
    let cachedUserLookup: [String: User]
    let messageComposerViewModel: MessageComposerViewModel
    @FocusState.Binding var focusedField: Field?

    var body: some View {
        ForEach(messageGroup.userGroups) { userGroup in
            if let user = cachedUserLookup[userGroup.userId] {
                MessageLayoutView(
                    user: user,
                    messages: userGroup.messages,
                    time: messageGroup.time,
                    messageComposerViewModel: messageComposerViewModel,
                    focusedField: $focusedField
                )
            }
        }
    }
}
