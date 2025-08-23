//
//  MessageCenter.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/21/25.
//

import SwiftUI

struct MessageCenter: View {
    @Binding var viewToShow: (() -> AnyView)?
    @State private var selectedFriend: UserInfo?
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    var body: some View {
        VStack {
            Text("Messages")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .center) {
                Button {
                    print("Search")
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(Color.buttonBackground)
                        .clipShape(.circle)
                }
                
                Button {
                    print("Add friends")
                } label: {
                    HStack {
                        Image(systemName: "person.fill.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Add Friends")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.buttonBackground)
                    .clipShape(.capsule)
                }
            }
            .bold()
            .foregroundStyle(.button)
            
            ScrollView {
                ScrollView([.horizontal]) {
                    HStack(spacing: 16) {
                        ForEach(userViewModel.friends) { friend in
                            UserIconView(user: friend, iconDimension: .init(width: 45, height: 45), origin: .friend)
                                .overlay(alignment: .bottomTrailing) {
                                    OnlineStatusCircle(status: friend.onlineStatus, color: .primaryBackground)
                                }
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.primaryBackground)
                                }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.vertical, 10)
                
                ForEach(userViewModel.friends) { friend in
                    Button {
                        selectedFriend = friend
                        viewToShow = {
                            AnyView(DirectMessageView())
                        }
                    } label: {
                        HStack {
                            UserIconView(user: friend, origin: .friend)
                                .overlay(alignment: .bottomTrailing) {
                                    OnlineStatusCircle(status: friend.onlineStatus, color: .secondaryBackground)
                                }
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(friend.displayName)
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text("1y")
                                        .font(.footnote)
                                }
                                Text("Mesage here")
                                    .font(.footnote)
                            }
                            .opacity(selectedFriend == friend ? 1 : 0.4)
                        }
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedFriend == friend ? .white.opacity(0.1) : .clear)
                        }
                    }
                    .tint(.white)
                }
            }
        }
        .padding()
        .onAppear {
            if let friend = userViewModel.friends.first {
                selectedFriend = friend
                viewToShow = {
                    AnyView(DirectMessageView())
                }
            }
            viewToShow = {
                AnyView(DirectMessageView())
            }
        }
    }
}
