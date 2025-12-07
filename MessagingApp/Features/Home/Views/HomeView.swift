//
//  HomeView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    
    @StateObject var homeViewModel = HomeViewModel()
    
    var body: some View {
        VStack {
            title

            addFriendNavLink
            
            channelScrollView
        }
        .modifier(HomeViewModifier())
        .modifier(MessageBubbleModifier(buttonAction: homeViewModel.showListFriend))
        .task {
            homeViewModel.listenForUpdates(
                userViewModel: userViewModel,
                channelViewModel: channelViewModel,
                friendViewModel: friendViewModel
            )
        }
        .onChange(of: channelViewModel.channels) { _, _ in
            homeViewModel.updateChannelToFriendMap(
                channelViewModel: channelViewModel,
                friendViewModel: friendViewModel,
                userViewModel: userViewModel
            )
        }
        .onChange(of: friendViewModel.friends) { _, _ in
            homeViewModel.updateChannelToFriendMap(
                channelViewModel: channelViewModel,
                friendViewModel: friendViewModel,
                userViewModel: userViewModel
            )
        }
        .onAppear {
            homeViewModel.updateChannelToFriendMap(
                channelViewModel: channelViewModel,
                friendViewModel: friendViewModel,
                userViewModel: userViewModel
            )
        }
        .sheet(isPresented: $homeViewModel.showFriendList) {
            FriendListView(selectedDmChannel: $homeViewModel.selectedChannel)
        }
    }
    
    var title: some View {
        Text("Messages")
            .font(.title3)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var addFriendNavLink: some View {
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
    }
    
    var validChannel: [(channel: Channel, friend: User)] {
        channelViewModel.channels.compactMap { channel in
            guard let channelId = channel.id, let friend = homeViewModel.channelToFriendMap[channelId] else {
                return nil
            }
            return (channel, friend)
        }
    }
    
    var channelScrollView: some View {
        ScrollView {
            ForEach(validChannel, id: \.channel.id) { pair in
                Button(action: { homeViewModel.updateSelectedChannel(with: pair.channel) }) {
                    ChannelPreview(
                        friend: pair.friend,
                        channel: pair.channel
                    )
                    .padding(10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .tint(.white)
            }
            .navigationDestination(item: $homeViewModel.selectedChannel) { destinationChannel in
                DirectMessageView(channelInfo: destinationChannel)
            }
        }
        .padding(.top)
    }
}
