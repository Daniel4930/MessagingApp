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
                HStack(spacing: 0) {
                    Spacer()
                    NavigationLink(destination: AccountSettingView()) {
                        Image(systemName: "gear")
                            .frame(width: 35, height: 35)
                            .contentShape(Rectangle())
                            .background {
                                Circle().fill(.buttonBackground.opacity(0.8))
                            }
                            .padding(.top)
                            .padding(.bottom, 40)
                            .modifier(TapGestureAnimation())
                            .overlay {
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            topBarHeight = proxy.size.height
                                        }
                                }
                            }
                    }
                    .padding(.top, viewTopSafeAreaInset)
                }
                
                userInfoSection()
            }
            .padding(.horizontal)
            .background(alignment: .top) {
                Color(hex: userViewModel.user!.bannerColor)
                    .frame(height: profileIconHeight / 2 + topBarHeight + viewTopSafeAreaInset)
            }
            
            NavigationLink(destination: EditProfileFormView()) {
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
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        viewTopSafeAreaInset = proxy.safeAreaInsets.top
                    }
            }
        }
    }
}
extension CustomizableProfileView {
    func userInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            let displayNameIsEmpty = userViewModel.user!.displayName.isEmpty
            
            Button {
                showOnlineStatus.toggle()
            } label: {
                UserIconView(urlString: userViewModel.user?.icon, iconDimension: CGSize(width: 100, height: 100), borderColor: Color("PrimaryBackgroundColor"), borderWidth: 5)
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
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            profileIconHeight = proxy.size.height
                        }
                }
            }
            .modifier(TapGestureAnimation())
            
            if !displayNameIsEmpty {
                Button {
                    showOnlineStatus.toggle()
                } label: {
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
