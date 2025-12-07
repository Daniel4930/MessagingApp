//
//  DirectMessageViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/22/25.
//

import Foundation
import SwiftUI

@MainActor
final class DirectMessageViewModel: ObservableObject {
    @Published var channelInfo: Channel
    
    init(channelInfo: Channel) {
        self.channelInfo = channelInfo
    }
    
    func startListeningForMessages(messageViewModel: MessageViewModel, userViewModel: UserViewModel) async {
        guard let id = channelInfo.id else {
            return
        }
        messageViewModel.listenForMessages(channelId: id, userViewModel: userViewModel)
    }
    
    func stopListeningForMessages(messageViewModel: MessageViewModel, showAttachmentSelector: Binding<Bool>) {
        messageViewModel.stopListening(channelId: channelInfo.id)
        showAttachmentSelector.wrappedValue = false
    }
}
