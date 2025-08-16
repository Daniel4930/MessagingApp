//
//  SignupView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI

struct SignupView: View {
    var body: some View {
        Button("Sign me up") {
            let userInfo = UserInfo(
                id: UUID(),
                email: "abc123@gmail.com",
                password: "123",
                userName: "Unlimited10",
                displayName: "Unlimited",
                registeredData: Date().formatted(),
                icon: "images/clyde-icon.png",
                onlineStatus: "online",
                aboutMe: "",
                bannerColor: "none",
                friends: []
            )
            
            Task {
                await FirebaseCloudStoreService.shared.addUser(user: userInfo)
            }
        }
    }
}
