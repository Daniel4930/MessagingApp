//
//  MessageScrollView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import SwiftUI

struct MessageScrollView: View {
    @FocusState.Binding var focusedField: Field?
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel

    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var keyboardProvider: KeyboardProvider
    @EnvironmentObject var appStateViewModel: AppStateViewModel

    @StateObject private var viewModel: MessageScrollViewViewModel
    
    private let channelInfo: Channel
    
    init(channelInfo: Channel, focusedField: FocusState<Field?>.Binding, messageComposerViewModel: MessageComposerViewModel) {
        self.channelInfo = channelInfo
        self._focusedField = focusedField
        self.messageComposerViewModel = messageComposerViewModel
        self._viewModel = StateObject(wrappedValue: MessageScrollViewViewModel(channelInfo: channelInfo))
    }

    var body: some View {
        scrollViewContent
            .modifier(MessageScrollViewScrollModifier(
                scrollPosition: $viewModel.scrollPosition,
                refreshAction: {
                    await viewModel.handleRefresh(messageViewModel: messageViewModel)
                }
            ))
            .onScrollPhaseChange { oldPhase, newPhase, context in
                viewModel.handleScrollPhaseChange(context: context, focusedField: &focusedField)
            }
            .onScrollTargetVisibilityChange(idType: String.self) { message in
                viewModel.updateScrollPosition(
                    messageId: message.first,
                    appStateViewModel: appStateViewModel
                )
            }
            .onChange(of: messageComposerViewModel.scrollToBottom) { _, newValue in
                viewModel.handleScrollToBottomChange(
                    newValue,
                    messageComposerViewModel: messageComposerViewModel
                )
            }
            .onChange(of: messageViewModel.messages) { _, _ in
                viewModel.updateCachedData(
                    messageViewModel: messageViewModel,
                    friendViewModel: friendViewModel,
                    userViewModel: userViewModel
                )
            }
            .onChange(of: friendViewModel.friends) { _, _ in
                viewModel.updateUserLookup(
                    friendViewModel: friendViewModel,
                    userViewModel: userViewModel
                )
            }
            .task {
                viewModel.updateCachedData(
                    messageViewModel: messageViewModel,
                    friendViewModel: friendViewModel,
                    userViewModel: userViewModel
                )
                viewModel.restoreScrollPosition(appStateViewModel: appStateViewModel)
            }
    }
}

// MARK: - View Components
extension MessageScrollView {
    private var scrollViewContent: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(viewModel.cachedDayGroups, id: \.date) { dayGroup in
                    DayGroupView(
                        dayGroup: dayGroup,
                        cachedUserLookup: viewModel.cachedUserLookup,
                        messageComposerViewModel: messageComposerViewModel,
                        focusedField: $focusedField
                    )
                }
            }
        }
    }
}

// MARK: - Day Group View
private struct DayGroupView: View {
    let dayGroup: MessageViewModel.DayGroup
    let cachedUserLookup: [String: User]
    let messageComposerViewModel: MessageComposerViewModel
    @FocusState.Binding var focusedField: Field?

    var body: some View {
        MessageDateView(date: dayGroup.date)
            .modifier(MessageDateViewModifier())

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

// MARK: - Message Group View
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
