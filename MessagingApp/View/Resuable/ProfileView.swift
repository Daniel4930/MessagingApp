//
//  ProfileView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//

import SwiftUI

struct ProfileView: View {
    let user: UserInfo
    @State private var showOptions: Bool = false
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        ScrollView {
            topBar
            
            userInfoSection
            
            if user.id != userViewModel.user?.id {
                ProfileAddAndMessageButton()
            }
            
            aboutMeSection
        }
        .opacity(showOptions ? 0.3 : 1)
        .defaultScrollAnchor(.top)
        .tint(Color("ButtonColor"))
        .padding()
        .background(Color("PrimaryBackgroundColor"))
    }
}

// MARK: - View Components
private extension ProfileView {
    var topBar: some View {
        HStack(spacing: 0) {
            Spacer()
            ellipsisButton
        }
        .overlay(alignment: .top) {
            LineIndicator()
        }
    }
    
    var ellipsisButton: some View {
        Button {
            showOptions.toggle()
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
        }
        .padding(.top)
        .padding(.bottom, 50)
        .popover(isPresented: $showOptions, attachmentAnchor: .point(.center), arrowEdge: .top) {
            ProfileOptionsView()
        }
    }
    
    var userInfoSection: some View {
        VStack(alignment: .leading) {
            UserIconView(user: user, iconDimension: CGSize(width: 100, height: 100))
                .overlay(alignment: .bottomTrailing) {
                    OnlineStatusCircle(
                        status: user.onlineStatus,
                        color: Color("PrimaryBackgroundColor"),
                        outterDimension: .init(width: 26, height: 26),
                        innerDimension: .init(width: 20, height: 20)
                    )
                    .offset(x: -3, y: -1)
                }
            Text(user.displayName)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(user.userName)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var aboutMeSection: some View {
        VStack(alignment: .leading) {
            Text("About Me")
                .font(.subheadline)
                .bold()
                .padding(.bottom, 7)
            
            Text(user.aboutMe)
                .padding(.bottom, 20)
            
            
            Text("Member Since")
                .font(.subheadline)
                .bold()
                .padding(.bottom, 4)
            Text(Date(timeIntervalSinceReferenceDate: TimeInterval(floatLiteral: user.registeredDate)).formatted(.dateTime.month(.abbreviated).day().year()))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("SecondaryBackgroundColor"))
        )
    }
    
    struct ProfileAddAndMessageButton: View {
        @EnvironmentObject var navViewModel: CustomNavigationViewModel
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            HStack {
                Spacer()
                ProfileActionButton(systemImageName: "message.fill", label: "Message") {
                    navViewModel.viewToShow = {
                        AnyView(DirectMessageView())
                    }
                    navViewModel.showView()
                    dismiss()
                }
                Spacer()
                ProfileActionButton(systemImageName: "person.fill.badge.plus", label: "Add friend") {
                    // Add friend action
                }
                Spacer()
            }
        }
        
        private struct ProfileActionButton: View {
            let systemImageName: String
            let label: String
            let action: () -> Void
            
            var body: some View {
                VStack {
                    Button(action: action) {
                        Image(systemName: systemImageName)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color("ButtonBackgroundColor"))
                            )
                    }
                    Text(label)
                        .font(.subheadline)
                }
            }
        }
    }
}

private struct ProfileOptionsView: View {
    var body: some View {
        VStack(spacing: 0) {
            ProfileOptionButton(title: "Invite to Server", action: {})
            DividerView()
            ProfileOptionButton(title: "Copy Username", action: {})
            DividerView()
            ProfileOptionButton(title: "Copy User ID", action: {})
            DividerView(thickness: 5)
            ProfileOptionButton(title: "Ignore", action: {})
            DividerView()
            ProfileOptionButton(title: "Block", isDestructive: true, action: {})
            DividerView()
            ProfileOptionButton(title: "Report User Profile", isDestructive: true, action: {})
        }
        .presentationCompactAdaptation(.popover)
    }
}

private struct ProfileOptionButton: View {
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .foregroundColor(isDestructive ? .red : nil)
        }
        .contentShape(Rectangle())
    }
}
