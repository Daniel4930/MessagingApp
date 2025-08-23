//
//  HomeView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

enum SidebarItem: Equatable {
    case messageCenter
    case server(String)
    case createServer
    case searchServer
}

struct HomeView: View {
    @Binding var viewToShow: (() -> AnyView)?
    @State private var selectedItem: SidebarItem = .messageCenter
    @EnvironmentObject var userViewModel: UserViewModel
    
    let sidebarItems: [SidebarItem] = [
        .messageCenter, .createServer, .searchServer
    ]
    
    var body: some View {
        HStack {
            //Side bar: Each items show a different view
            ScrollView {
                ForEach(Array(sidebarItems.indices), id: \.self) { index in
                    let currentItem = sidebarItems[index]
                    SidebarItemView(currentItem: currentItem, selectedItem: $selectedItem)
                }
            }
            .frame(width: 70)
            .padding(.top)
            
            //content: Show based on the selected item in the side bar
            Group {
                switch selectedItem {
                case .messageCenter:
                    MessageCenter(viewToShow: $viewToShow)
                case .server(_):
                    NavigationLink("Direct message view") {
                        DirectMessageView()
                    }
                case .createServer:
                    NavigationLink("Direct message view") {
                        DirectMessageView()
                    }
                case .searchServer:
                    NavigationLink("Direct message view") {
                        DirectMessageView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: 20, topTrailing: 20)
                )
                .fill(Color.secondaryBackground)
                .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//#Preview {
//    TabsView()
//        .environmentObject(UserViewModel())
//        .environmentObject(MessageViewModel())
//}
