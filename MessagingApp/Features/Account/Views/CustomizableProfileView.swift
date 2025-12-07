//
//  CustomizableProfileView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/2/25.
//

import SwiftUI
import FirebaseCore

struct CustomizableProfileView: View {
    @State private var showOnlineStatus = false
    @State private var profileIconHeight: CGFloat = .zero
    @State private var viewTopSafeAreaInset: CGFloat = .zero
    @State private var topBarHeight: CGFloat = .zero
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                settingIconView
                
                userInfoView
            }
            .padding(.horizontal)
            .background(alignment: .top) {
                bannerColorView
            }
            
            NavigationLink(destination: EditProfileFormView()) {
                editProfileView
            }
            .modifier(TapGestureAnimation())
            
            ProfileAboutMeView(user: userViewModel.user!)
                .padding(.horizontal)
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .defaultScrollAnchor(.top)
        .tint(Color("ButtonColor"))
        .background(Color("PrimaryBackgroundColor"))
        .sheet(isPresented: $showOnlineStatus) {
            ChangeOnlineStatusView(selectedItem: userViewModel.user!.onlineStatus)
                .presentationDetents([.medium])
        }
        .overlay {
            topSafeAreaHeightReaderView
        }
    }
}

// MARK: - View components
extension CustomizableProfileView {
    var settingIconView: some View {
        HStack(spacing: 0) {
            Spacer()
            NavigationLink(destination: AccountSettingView()) {
                Image(systemName: "gear")
                    .frame(width: 35, height: 35)
                    .background {
                        Circle().fill(.buttonBackground.opacity(0.8))
                    }
                    .padding(.top)
                    .padding(.bottom, 40)
            }
            .modifier(TapGestureAnimation())
            .background {
                topBarHeightReaderView
            }
            .padding(.top, viewTopSafeAreaInset)
        }
    }
    
    var topBarHeightReaderView: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    topBarHeight = proxy.size.height
                }
        }
    }
    
    var topSafeAreaHeightReaderView: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    viewTopSafeAreaInset = proxy.safeAreaInsets.top
                }
        }
    }
    
    @ViewBuilder var userInfoView: some View {
        let displayNameIsEmpty = userViewModel.user!.displayName.isEmpty
        
        VStack(alignment: .leading, spacing: 0) {
            Button(action: showOnlineStatusOptions) {
                UserIconView(
                    urlString: userViewModel.user?.icon,
                    iconDimension: CGSize(width: 100, height: 100),
                    borderColor: Color("PrimaryBackgroundColor"),
                    borderWidth: 5
                )
                .overlay(alignment: .bottomTrailing) {
                    OnlineStatusCircle(
                        status: userViewModel.user!.onlineStatus.rawValue,
                        color: Color("PrimaryBackgroundColor"),
                        outterDimension: .init(width: 26, height: 26),
                        innerDimension: .init(width: 20, height: 20)
                    )
                    .offset(x: -3, y: -1)
                }
            }
            .padding(.bottom, 10)
            .overlay {
                profileIconHeightReaderView
            }
            .modifier(TapGestureAnimation())
            
            namesView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder var namesView: some View {
        let displayNameIsEmpty = userViewModel.user!.displayName.isEmpty
        
        if !displayNameIsEmpty {
            Button(action: showOnlineStatusOptions) {
                HStack {
                    Text(userViewModel.user!.displayName)
                        .font(.title2.bold())
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(.button)
                }
            }
        }
        
        Text(userViewModel.user!.userName)
            .font(displayNameIsEmpty ? .title2 : .body)
            .bold(displayNameIsEmpty)
    }
    
    var profileIconHeightReaderView: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    profileIconHeight = proxy.size.height
                }
        }
    }
    
    @ViewBuilder var bannerColorView: some View {
        if let user = userViewModel.user {
            Color(hex: user.bannerColor)
                .frame(height: profileIconHeight / 2 + topBarHeight + viewTopSafeAreaInset)
        }
    }
    
    var editProfileView: some View {
        HStack(alignment: .center) {
            Image(systemName: "pencil")
            Text("Edit Profile")
        }
        .bold()
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .foregroundStyle(.white)
        .background {
            Capsule()
                .fill(.blue)
        }
        .padding()
    }
}

// MARK: - View actions
extension CustomizableProfileView {
    func showOnlineStatusOptions() {
        showOnlineStatus.toggle()
    }
}
