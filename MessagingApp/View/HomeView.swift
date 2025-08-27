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
    @State private var selectedItem: SidebarItem = .messageCenter
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
    
    let sidebarItems: [SidebarItem] = [
        .messageCenter, .createServer, .searchServer
    ]
    
    var body: some View {
        HStack {
            ScrollView {
                ForEach(Array(sidebarItems.indices), id: \.self) { index in
                    let currentItem = sidebarItems[index]
                    SidebarItemView(currentItem: currentItem, selectedItem: $selectedItem)
                }
            }
            .frame(width: 70)
            .padding(.top)
            
            Group {
                switch selectedItem {
                case .messageCenter:
                    MessageCenter()
                case .server(_):
                    Text("Server")
                case .createServer:
                    Text("Create a new server")
                case .searchServer:
                    Text("Search a server")
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
        .onChange(of: selectedItem) { oldValue, newValue in
            navViewModel.gestureDisabled = selectedItem == .messageCenter ? false : true
        }
    }
}
