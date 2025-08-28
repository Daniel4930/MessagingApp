//
//  NavigationTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI

struct NavigationTopBar: View {
    let channelInfo: Channel
    @State private var usersInConversation: [User] = []
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    
    var body: some View {
        HStack {
            Button {
                navViewModel.hideView()
            } label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 25, height: 20)
                    .bold()
            }
            HStack {
                if !usersInConversation.isEmpty {
                    if usersInConversation.count == 1, let friend = usersInConversation.first {
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
                        //TODO: Show multiple icon and a long list of names
                    }
                } else {
                    Text("Unable to get user information")
                }
            }
        }
        .task {
            if channelInfo.type == ChannelType.dm.rawValue {
                guard let friend = channelViewModel.dmChannelsMapWithFriends.first(where: { $0.channel == channelInfo })?.friend else { return }
                usersInConversation.append(friend)
            } else {
                //TODO: Handle channel with multiple users
            }
        }
    }
}
