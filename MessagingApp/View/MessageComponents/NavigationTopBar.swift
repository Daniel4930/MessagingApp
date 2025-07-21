//
//  NavigationTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI

struct NavigationTopBar: ToolbarContent {
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    let backButtonWidth: CGFloat = 19
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: backButtonWidth)
                    .bold()
            }
            HStack {
                if let friend = getFriend() {
                    IconView(user: friend)
                    
                    Text(friend.displayName ?? "")
                        .font(.title3)
                        .bold()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 5, height: 10)
                        .bold()
                } else {
                    Text("Unable to get user information")
                }
            }
        }
    }
}
extension NavigationTopBar {
    func getFriend() -> User? {
        if let friends = userViewModel.user?.friends?.allObjects, let first = friends.first as? User {
            guard let id = first.id else { return nil }
            return userViewModel.fetchUser(id: id)
        }
        return nil
    }
}


