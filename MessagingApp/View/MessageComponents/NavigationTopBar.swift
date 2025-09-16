//
//  NavigationTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI

struct NavigationTopBar: View {
    let channelInfo: Channel
    @Binding var showFileAndImageSelector: Bool
    @EnvironmentObject var friendViewModel: FriendViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            Button {
                showFileAndImageSelector = false
                dismiss()
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
                else if let friend = friendViewModel.getFriendDmChannel(memberIds: channelInfo.memberIds) {
                    UserIconView(urlString: friend.icon)
                        .overlay(alignment: .bottomTrailing) {
                            OnlineStatusCircle(status: friend.onlineStatus.rawValue, color: Color("PrimaryBackgroundColor"))
                        }
                    
                    Text(friend.displayName.isEmpty ? friend.userName : friend.displayName)
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
