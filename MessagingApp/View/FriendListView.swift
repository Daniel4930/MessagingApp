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
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
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
                    Button {
                        guard let currentUserId = userViewModel.user?.id else { return }
                        guard let channel = channelViewModel.findOrCreateDmChannel(currentUserId: currentUserId, otherUser: friend) else { return }
                        
                        navViewModel.viewToShow = {
                            AnyView(DirectMessageView(channelInfo: channel))
                        }
                        navViewModel.showView()
                        selectedDmChannel = channel.id != nil ? channel : nil
                        dismiss()
                    } label: {
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
                        }
                    }
                    .tint(.white)
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
