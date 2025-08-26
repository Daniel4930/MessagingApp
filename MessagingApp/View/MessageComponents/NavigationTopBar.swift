//
//  NavigationTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI

struct NavigationTopBar: View {
    let backButtonWidth: CGFloat = 19
    @EnvironmentObject var friendViewModel: FriendViewModel
    
    var body: some View {
        HStack {
            Button {

            } label: {
                Image(systemName: "arrow.left")
                    .bold()
            }
            HStack {
                if let friend = friendViewModel.friends.first {
                    UserIconView(user: friend)
                        .overlay(alignment: .bottomTrailing) {
                            OnlineStatusCircle(status: friend.onlineStatus, color: Color("PrimaryBackgroundColor"))
                        }
                    
                    Text(friend.displayName)
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
