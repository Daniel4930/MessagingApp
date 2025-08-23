//
//  TabsView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/20/25.
//

import SwiftUI

enum CurrentTab {
    case home
    case notifications
    case account
}

struct TabsView: View {
    @Binding var xOffset: CGFloat
    
    @State private var selection: CurrentTab = .home
    @State private var viewToShow: (() -> AnyView)?
    @EnvironmentObject var userViewModel: UserViewModel
    
    let iconDimension: CGSize = CGSize(width: 25, height: 25)
    let tabsInfo: [(tab: CurrentTab, title: String, icon: String)] = [
        (.home, "Home", "house.fill"),
        (.notifications, "Notifications", "bell.fill"),
        (.account, "Account", "USER_ICON")
    ]
    
    var body: some View {
        VStack(spacing: 0) {            
            switch selection {
            case .home:
                HomeView(viewToShow: $viewToShow)
            case .notifications:
                Text("Notifications")
            case .account:
                if let user = userViewModel.user {
                    ProfileView(user: user)
                }
            }
            
            HStack(alignment: .center) {
                ForEach(tabsInfo, id: \.tab) { info in
                    Spacer()
                    VStack(alignment: .center, spacing: 1) {
                        tabIcon(icon: info.icon, tab: info.tab)
                        
                        Text(info.title)
                            .font(.footnote)
                    }
                    .foregroundStyle(Color.button.opacity(selection == info.tab ? 1 : 0.5))
                    .onTapGesture {
                        selection = info.tab
                    }
                }
                Spacer()
            }
            .padding(.top, 10)
            .background(Color.secondaryBackground)
            .overlay(alignment: .top) {
                DividerView(color: Color.button.opacity(0.5), thickness: 1)
            }
        }
        .overlay(alignment: .trailing) {
            if let view = viewToShow {
                view()
                    .offset(x: xOffset)
            }
        }
    }
}
extension TabsView {
    @ViewBuilder func tabIcon(icon: String, tab: CurrentTab) -> some View {
        if icon == "USER_ICON", let user = userViewModel.user {
            UserIconView(
                user: nil,
                iconDimension: iconDimension,
                borderColor: Color.primaryBackground.opacity(selection == tab ? 1 : 0.5),
                origin: .user
            )
                .overlay(alignment: .bottomTrailing) {
                    OnlineStatusCircle(
                        status: user.onlineStatus,
                        color: Color.secondaryBackground.opacity(selection == tab ? 1 : 0.5)
                    )
                        .offset(x: 8, y: 5)
                }
        } else {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconDimension.width, height: iconDimension.height)
                .clipShape(Circle())
        }
    }
}
