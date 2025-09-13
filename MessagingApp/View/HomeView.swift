//
//  HomeView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

enum SidebarItem: Equatable {
    case messageCenter
    case server(String)
    case createServer
    case searchServer
}

struct HomeView: View {
    var body: some View {
        MessageCenter()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: 20, topTrailing: 20)
                )
                .fill(Color.secondaryBackground)
                .opacity(0.5)
            }
    }
}
