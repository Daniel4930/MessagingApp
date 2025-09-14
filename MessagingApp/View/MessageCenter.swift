//
//  MessageCenter.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/21/25.
//

import SwiftUI

struct MessageCenter: View {
    @State private var selectedDmChannel: Channel?
    @State private var selectedFriendIcon: User?
    @State private var showFriendList = false
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    
    var body: some View {
        VStack {
            Text("Messages")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            NavigationLink(destination: AddFriendView()) {
                HStack {
                    Image(systemName: "person.fill.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Add Friends")
                }
                .frame(maxWidth: .infinity)
                .bold()
                .foregroundStyle(.button)
                .padding(8)
                .background(Color.buttonBackground)
                .clipShape(.capsule)
            }
            
            ScrollView {
                FriendsHorizontalView(selectedFriendIcon: $selectedFriendIcon)
                    .scrollIndicators(.hidden)
                    .padding(.vertical, 10)
                
                ForEach(channelViewModel.dmChannelsMapWithFriends, id: \.channel.id) { map in
                    let friend = map.friend
                    let channel = map.channel
                    
                    Button {
                       selectedDmChannel = channel
                    } label: {
                        ChannelPreview(
                            friend: friend,
                            channel: channel
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                    }
                    .tint(.white)
                }
                .navigationDestination(item: $selectedDmChannel) { destinationChannel in
                    DirectMessageView(channelInfo: destinationChannel)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showFriendList.toggle()
                } label: {
                    Image(systemName: "message.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(.white)
                        .padding()
                        .background {
                            Circle()
                                .fill(.blue)
                        }
                }
                .padding([.trailing, .bottom], 10)
            }
        }
        .padding()
        .task {
            guard let currentUser = userViewModel.user, let userId = currentUser.id else { return }
            channelViewModel.listenForChannels(userId: userId, friends: friendViewModel.friends)
            userViewModel.listenForUserChanges(userId: userId)
        }
        .sheet(item: $selectedFriendIcon) { friend in
            ProfileView(user: friend)
                .presentationDetents([.fraction(0.95)])
        }
        .sheet(isPresented: $showFriendList) {
            FriendListView(selectedDmChannel: $selectedDmChannel)
        }
    }
}
