//
//  SendAttachmentsButtonView.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/2/25.
//

import SwiftUI

struct SendAttachmentsButtonView: View {
    @Binding var channel: Channel
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var height: CGFloat
    @Binding var sendButtonDisabled: Bool
    let minHeight: CGFloat
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    
    var body: some View {
        ZStack {
            linearGradient
                .allowsHitTesting(false)
                .overlay(alignment: .bottomTrailing) {
                    overlayButton
                        .padding([.trailing, .vertical], 20)
                        .disabled(sendButtonDisabled)
                }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: View components
extension SendAttachmentsButtonView {
    var linearGradient: some View {
        LinearGradient(
            stops: [
                .init(color: Color.black.opacity(0.0), location: 0.8),
                .init(color: Color.black.opacity(0.6), location: 0.9),
                .init(color: Color.black.opacity(0.9), location: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var overlayButton: some View {
        SendButtonView(action: sendButtonAction)
    }
}

// MARK: View actions
extension SendAttachmentsButtonView {
    func sendButtonAction() {
        Task {
            try await messageViewModel.sendMessage(
                sendButtonDisabled: $sendButtonDisabled,
                channel: $channel,
                messageComposerViewModel: messageComposerViewModel,
                channelViewModel: channelViewModel,
                userViewModel: userViewModel,
                alertViewModel: alertViewModel
            )
        }
        height = minHeight
    }
}
