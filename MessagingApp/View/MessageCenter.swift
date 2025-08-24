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
    @State private var selectedIcon: UserInfo?
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
                let friends = userViewModel.friends
                ScrollView([.horizontal]) {
                    HStack(spacing: 16) {
                        ForEach(Array(friends.indices), id: \.self) { index in
                            Button {
                                selectedIcon = friends[index]
                            } label: {
                                UserIconView(user: friends[index], iconDimension: .init(width: 45, height: 45))
                                    .overlay(alignment: .bottomTrailing) {
                                        OnlineStatusCircle(status: friends[index].onlineStatus, color: .primaryBackground)
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
                
                ForEach(Array(friends.indices), id: \.self) { index in
                    Button {
                        selectedFriend = friends[index]
                        viewToShow = {
                            AnyView(
                                DirectMessageView()
                            )
                        }
                    } label: {
                        HStack {
                            UserIconView(user: friends[index])
                                .overlay(alignment: .bottomTrailing) {
                                    OnlineStatusCircle(status: friends[index].onlineStatus, color: .secondaryBackground)
                                }
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(friends[index].displayName)
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text("1y")
                                        .font(.footnote)
                                }
                                Text("Mesage here")
                                    .font(.footnote)
                            }
                            .opacity(selectedFriend == friends[index] ? 1 : 0.4)
                        }
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedFriend == friends[index] ? .white.opacity(0.1) : .clear)
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
        .sheet(item: $selectedIcon) { friend in
            ProfileView(user: friend)
        }
    }
}
