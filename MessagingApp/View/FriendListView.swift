//
//  FriendListView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/2/25.
//

import SwiftUI

struct FriendListView: View {
    @Binding var selectedDmChannel: Channel?
    
    @State private var nameToSearch: String = ""
    @State private var listItemWidth: CGFloat = .zero
    
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    var searchResult: [User] {
        let friends = friendViewModel.friends
        
        if nameToSearch.isEmpty {
            return friends
        } else {
            return friends.filter { $0.displayName.localizedStandardContains(nameToSearch) || $0.userName.localizedStandardContains(nameToSearch) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResult, id: \.self) { friend in
                    HStack(alignment: .center) {
                        UserIconView(urlString: friend.icon)
                        
                        VStack(alignment: .leading) {
                            let displayNameIsEmpty = friend.displayName.isEmpty
                            
                            if !displayNameIsEmpty {
                                Text(friend.displayName)
                                    .bold()
                            }
                            Text(friend.userName)
                                .font(displayNameIsEmpty ? .body : .footnote)
                                .bold(displayNameIsEmpty)
                        }
                        
                        Spacer()
                        
                        Button {
                            guard let currentUserId = userViewModel.user?.id else { return }
                            guard let channel = channelViewModel.findOrCreateDmChannel(currentUserId: currentUserId, otherUser: friend) else { return }
                            
                            selectedDmChannel = channel
                            dismiss()
                        } label: {
                            Image(systemName: "message.fill")
                        }
                        .modifier(ListButtonModifer(backgroundColor: .blue, listItemWidth: listItemWidth))
                        
                        Button {
                            guard let user = userViewModel.user else { return }
                            guard let friendId = friend.id else { return }
                            Task {
                                await friendViewModel.removeFriend(for: user, friendId: friendId)
                            }
                        } label: {
                            Image(systemName: "person.fill.badge.minus")
                        }
                        .modifier(ListButtonModifer(backgroundColor: .red, listItemWidth: listItemWidth))
                    }
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { listItemWidth = proxy.size.width * 0.1 }
                                .allowsHitTesting(false)
                        }
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.borderless)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Message")
                        .font(.title3.bold())
                }
            }
        }
        .searchable(text: $nameToSearch, prompt: Text("Search your friends"))
    }
}
extension FriendListView {
    private struct ListButtonModifer: ViewModifier {
        let backgroundColor: Color
        let listItemWidth: CGFloat
        
        func body(content: Content) -> some View {
            content
                .tint(.white)
                .frame(width: listItemWidth)
                .padding()
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }
}
