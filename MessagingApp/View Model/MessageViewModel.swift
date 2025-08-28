//
//  MessageViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import Foundation

@MainActor
class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
}
