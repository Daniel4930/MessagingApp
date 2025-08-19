//
//  NavigationTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI

struct NavigationTopBar: ToolbarContent {
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    let backButtonWidth: CGFloat = 19
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: backButtonWidth)
                    .bold()
            }
            HStack {
                if let friend = userViewModel.friends.first {
                    IconView(user: friend)
                        .overlay(alignment: .bottomTrailing) {
                            OnlineStatusCircle(status: friend.onlineStatus, color: Color("PrimaryBackgroundColor"))
                        }
                    
                    Text(friend.displayName ?? "")
                        .font(.title3)
                        .bold()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 5, height: 10)
                        .bold()
                } else {
                    Text("Unable to get user information")
                }
            }
        }
    }
}
