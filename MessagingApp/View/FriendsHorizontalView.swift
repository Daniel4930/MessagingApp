//
//  FriendsHorizontalView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/13/25.
//

import SwiftUI

struct FriendsHorizontalView: View {
    @Binding var selectedFriendIcon: User?
    @EnvironmentObject var friendViewModel: FriendViewModel
    
    var body: some View {
        ScrollView([.horizontal]) {
            HStack(spacing: 16) {
                let sortedFriends = friendViewModel.friends.sorted { $0.onlineStatus.sortOrder < $1.onlineStatus.sortOrder }
                
                ForEach(sortedFriends, id: \.id) { friend in
                    Button {
                        selectedFriendIcon = friend
                    } label: {
                        UserIconView(urlString: friend.icon, iconDimension: .init(width: 45, height: 45))
                            .overlay(alignment: .bottomTrailing) {
                                OnlineStatusCircle(status: friend.onlineStatus.rawValue, color: .primaryBackground)
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.primaryBackground)
                            }
                    }
                    .tint(.white)
                    .modifier(TapGestureAnimation())
                }
            }
        }
    }
}
