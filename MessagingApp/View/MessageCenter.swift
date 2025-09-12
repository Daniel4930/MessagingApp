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
    @State private var showSearchUser = false
    @State private var showAddFriend = false
    @State private var showFriendList = false
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
    
    var body: some View {
        VStack {
            Text("Messages")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                showAddFriend = true
                navViewModel.exitSwipeAction = {
                    showAddFriend = false
                }
            } label: {
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
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.vertical, 10)
                
                ForEach(channelViewModel.dmChannelsMapWithFriends, id: \.channel.id) { map in
                    let friend = map.friend
                    let channel = map.channel
                    
                    Button {
                        selectedDmChannel = channel
                        navViewModel.viewToShow = {
                            AnyView(
                                DirectMessageView(channelInfo: channel)
                            )
                        }
                        navViewModel.showView()
                    } label: {
                        HStack {
                            UserIconView(urlString: friend.icon)
                                .overlay(alignment: .bottomTrailing) {
                                    OnlineStatusCircle(status: friend.onlineStatus.rawValue, color: .secondaryBackground)
                                }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                let nameToShow = friend.displayName.isEmpty ? friend.userName : friend.displayName
                                
                                HStack {
                                    Text(nameToShow)
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    if let latestMessage = channel.lastMessage {
                                        Text(channelViewModel.formatLastMessageTime(time: latestMessage.timestamp.dateValue()))
                                            .font(.footnote)
                                    }
                                }
                                
                                if let latestMessage = channel.lastMessage {
                                    let sender = latestMessage.senderId == friend.id ? nameToShow : "You"
                                    if let text = latestMessage.text {
                                        Text("\(sender): \(text)")
                                            .font(.footnote)
                                            .lineLimit(1)
                                    }
                                } else {
                                    Text("No messages yet.")
                                        .font(.footnote)
                                }
                            }
                            .opacity(selectedDmChannel?.id == channel.id ? 1 : 0.4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedDmChannel?.id == channel.id ? .white.opacity(0.1) : .clear)
                        }
                    }
                    .tint(.white)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showFriendList = true
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
        .onAppear {
            selectedDmChannel = channelViewModel.dmChannelsMapWithFriends.first?.channel
            if let selectedDmChannel {
                navViewModel.viewToShow = {
                    AnyView(DirectMessageView(channelInfo: selectedDmChannel))
                }
            }
        }
        .onChange(of: channelViewModel.dmChannelsMapWithFriends) { oldMap, newMap in
            if selectedDmChannel == nil, let first = newMap.first {
                selectedDmChannel = first.channel
                navViewModel.viewToShow = {
                    AnyView(DirectMessageView(channelInfo: first.channel))
                }
            }
        }
        .onChange(of: showAddFriend) { oldValue, newValue in
            if newValue {
                navViewModel.viewToShow = {
                    AnyView(
                        AddFriendView(showAddFriend: $showAddFriend)
                            .background(Color.primaryBackground)
                            .onTapGesture {
                                hideKeyboard()
                            }
                    )
                }
                navViewModel.showView()
            } else {
                hideKeyboard()
                navViewModel.hideView() {
                    if let selectedDmChannel {
                        navViewModel.viewToShow = {
                            AnyView(DirectMessageView(channelInfo: selectedDmChannel))
                        }
                    } else {
                        navViewModel.viewToShow = nil
                    }
                }
            }
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
