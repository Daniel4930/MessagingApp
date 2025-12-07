//
//  ProfileAboutMeView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/3/25.
//

import SwiftUI

struct ProfileAboutMeView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading) {
            aboutMeView
            
            memberSinceDateView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("SecondaryBackgroundColor"))
        )
    }
}

// MARK: - View components
extension ProfileAboutMeView {
    @ViewBuilder var aboutMeView: some View {
        if !user.aboutMe.isEmpty {
            Text("About Me")
                .font(.headline.bold())
                .padding(.bottom, 7)
            
            Text(user.aboutMe)
                .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder var memberSinceDateView: some View {
        Text("Member Since")
            .font(.headline.bold())
            .padding(.bottom, 4)
        
        if let registeredDate = user.registeredDate {
            Text(registeredDate.dateValue().formatted(.dateTime.month(.abbreviated).day().year()))
                .font(.subheadline)
        }
    }
}
