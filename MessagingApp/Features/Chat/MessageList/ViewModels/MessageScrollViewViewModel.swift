//
//  MessageScrollViewViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/27/25.
//

import Foundation
import SwiftUI

@MainActor
final class MessageScrollViewViewModel: ObservableObject {
    @Published var scrollPosition = ScrollPosition(idType: String.self)
    @Published var cachedDayGroups: [MessageViewModel.DayGroup] = []
    @Published var cachedUserLookup: [String: User] = [:]
    @Published private var lastMessageCount: Int = 0
    
    let channelInfo: Channel
    
    init(channelInfo: Channel) {
        self.channelInfo = channelInfo
    }
    
    // MARK: - Scroll Actions
    
    func scrollToBottom(messageComposerViewModel: MessageComposerViewModel) {
        scrollPosition.scrollTo(edge: .bottom)
        messageComposerViewModel.scrollToBottom = false
    }
    
    func restoreScrollPosition(appStateViewModel: AppStateViewModel) {
        guard !cachedDayGroups.isEmpty, let id = channelInfo.id else { return }
        
        // Use center anchor for better visual positioning
        let previousMessageScrollPositionId = appStateViewModel.previousScrollPositionId[id]
        
        scrollPosition.scrollTo(id: previousMessageScrollPositionId, anchor: .center)
    }
    
    func updateScrollPosition(messageId: String?, appStateViewModel: AppStateViewModel) {
        guard let messageId, let id = channelInfo.id else { return }
        appStateViewModel.previousScrollPositionId[id] = messageId
    }
    
    // MARK: - Message Actions
    
    func handleRefresh(messageViewModel: MessageViewModel) async {
        guard let channelId = channelInfo.id else { return }
        await messageViewModel.fetchMoreMessages(channelId: channelId)
    }
    
    // MARK: - Data Management
    
    func updateCachedData(
        messageViewModel: MessageViewModel,
        friendViewModel: FriendViewModel,
        userViewModel: UserViewModel
    ) {
        let messages = messageViewModel.messages.first(where: { $0.channelId == channelInfo.id })?.messages ?? []

        // Always recompute when messages change - this ensures isPending updates are reflected
        if messages.count != lastMessageCount || cachedDayGroups.isEmpty {
            lastMessageCount = messages.count
        }
        
        cachedDayGroups = messageViewModel.groupedMessages(messages: messages)
        updateUserLookup(friendViewModel: friendViewModel, userViewModel: userViewModel)
    }
    
    func updateUserLookup(friendViewModel: FriendViewModel, userViewModel: UserViewModel) {
        // Ensure we have data to work with
        guard !cachedDayGroups.isEmpty else {
            cachedUserLookup = [:]
            return
        }

        var lookup: [String: User] = [:]

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
    
    // MARK: - Event Handlers
    func handleScrollPhaseChange(context: ScrollPhaseChangeContext, focusedField: inout Field?) {
        if let dy = context.velocity?.dy, abs(dy) >= 1.5 {
            focusedField = nil
        }
    }
    
    func handleScrollToBottomChange(_ newValue: Bool, messageComposerViewModel: MessageComposerViewModel) {
        if newValue == true {
            scrollToBottom(messageComposerViewModel: messageComposerViewModel)
        }
    }
}
