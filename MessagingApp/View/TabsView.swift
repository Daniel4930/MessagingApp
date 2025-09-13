//
//  TabsView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/20/25.
//

import SwiftUI

enum Tabs {
    case home
    case notifications
    case account
}

struct TabsView: View {
    @State private var selection: Tabs = .home
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
    @EnvironmentObject var keyboardProvider: KeyboardProvider
    
    let iconDimension: CGSize = CGSize(width: 25, height: 25)
    let tabsInfo: [(tab: Tabs, title: String, icon: String)] = [
        (.home, "Home", "house.fill"),
        (.notifications, "Notifications", "bell.fill"),
        (.account, "Account", "person.fill")
    ]
    
    var body: some View {
        VStack(spacing: 0) {            
            switch selection {
            case .home:
                HomeView()
            case .notifications:
                NotificationView(userId: userViewModel.user?.id)
            case .account:
                CustomizableProfileView()
            }
            
            HStack(alignment: .center) {
                ForEach(tabsInfo, id: \.tab) { info in
                    Spacer()
                    VStack(alignment: .center, spacing: 1) {
                        tabIcon(icon: info.icon, tab: info.tab)
                        
                        Text(info.title)
                            .font(.footnote)
                    }
                    .foregroundStyle(Color.button.opacity(selection == info.tab ? 1 : 0.4))
                    .onTapGesture {
                        selection = info.tab
                        navViewModel.gestureDisabled = selection == .home ? false : true
                    }
                }
                Spacer()
            }
            .padding(.top, 10)
            .background(Color.secondaryBackground.opacity(0.6))
            .overlay(alignment: .top) {
                DividerView(color: Color.button.opacity(0.2), thickness: 1)
            }
        }
        .overlay(alignment: .trailing) {
            if let view = navViewModel.viewToShow {
                view()
                    .offset(x: navViewModel.totalXOffset())
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    navViewModel.onDragChanged(value: value)
                }
                .onEnded(navViewModel.onDragEnded(_:))
            , isEnabled: !navViewModel.gestureDisabled
        )
    }
}
extension TabsView {
    @ViewBuilder func tabIcon(icon: String, tab: Tabs) -> some View {
        if tab == .account, let user = userViewModel.user {
            UserIconView(
                urlString: user.icon,
                iconDimension: iconDimension,
                borderColor: Color.primaryBackground.opacity(selection == tab ? 1 : 0.4),
            )
                .overlay(alignment: .bottomTrailing) {
                    OnlineStatusCircle(
                        status: user.onlineStatus.rawValue,
                        color: Color.secondaryBackground
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
