//
//  HomeView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = userViewModel.user {
                    if user.userName.isEmpty {
                        NewUserView()
                    } else {
                        NavigationLink("Direct message view") {
                            DirectMessageView()
                        }
                        Spacer()
                    }
                } else {
                    ProgressView("Fetching user…")
                        .foregroundStyle(.white)
                }
            }
            .padding()
        }
    }
}
