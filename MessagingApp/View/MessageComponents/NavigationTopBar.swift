//
//  NavigationTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI

struct NavigationTopBar: View {
    let channelInfo: Channel
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
            }
            .tint(.white)
            
            HStack {
                if channelInfo.memberIds.isEmpty {
                    Text("Unable to get user information")
                }
                else if channelInfo.type == ChannelType.dm.rawValue, let friend = friendViewModel.getFriendDmChannel(memberIds: channelInfo.memberIds) {
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
                }
            }
        }
    }
}
