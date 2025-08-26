//
//  ChannelViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/25/25.
//

import Foundation

class ChannelViewModel: ObservableObject {
    @Published var channels: [String:MessageInfo] = [:]
}
