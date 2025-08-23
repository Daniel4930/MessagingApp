//
//  SidebarItemView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/21/25.
//

import SwiftUI

struct SidebarItemView: View {
    let currentItem: SidebarItem
    @Binding var selectedItem: SidebarItem
    @State private var indicatorHeight: CGFloat = .zero
    static let idicatorMaxHeight: CGFloat = 40
    static let itemSize: CGSize = .init(width: 23, height: 23)
    static let space: CGFloat = 14
    
    var body: some View {
        HStack(spacing: 5) {
            LineIndicator(color: selectedItem == currentItem ? .white : .clear, width: 3, height: indicatorHeight)
                .animation(.smooth, value: indicatorHeight)
            
            Button {
                selectedItem = currentItem
            } label: {
                switch currentItem {
                case .messageCenter:
                    Image(systemName: "message.fill")
                        .sidebarItemStyle(dimension: SidebarItemView.itemSize, space: SidebarItemView.space)
                        .animation(.smooth, value: selectedItem)
                        .foregroundStyle(.white.opacity(currentItem == selectedItem ? 1 : 0.5))
                        .background(currentItem == selectedItem ? .blue : .buttonBackground)
                        .clipShape(RoundedRectangle(cornerRadius: currentItem == selectedItem ? 15 : .infinity))
                case .server(_):
                    
                    //TODO: Change this later
                    Image(systemName: "message.fill")
                        .sidebarItemStyle(dimension: SidebarItemView.itemSize, space: SidebarItemView.space)
                        .animation(.smooth, value: selectedItem)
                        .clipShape(RoundedRectangle(cornerRadius: currentItem == selectedItem ? 15 : .infinity))
                case .createServer:
                    Image(systemName: "plus")
                        .sidebarItemStyle(dimension: SidebarItemView.itemSize, space: SidebarItemView.space)
                        .animation(.smooth, value: selectedItem)
                        .foregroundStyle(.green.opacity(currentItem == selectedItem ? 1 : 0.5))
                        .background(.buttonBackground)
                        .clipShape(RoundedRectangle(cornerRadius: currentItem == selectedItem ? 15 : .infinity))
                case .searchServer:
                    Image(systemName: "magnifyingglass")
                        .sidebarItemStyle(dimension: SidebarItemView.itemSize, space: SidebarItemView.space)
                        .animation(.smooth, value: selectedItem)
                        .foregroundStyle(.green.opacity(currentItem == selectedItem ? 1 : 0.5))
                        .background(.buttonBackground)
                        .clipShape(RoundedRectangle(cornerRadius: currentItem == selectedItem ? 15 : .infinity))
                }
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            if newValue != currentItem {
                indicatorHeight = .zero
            } else {
                indicatorHeight = SidebarItemView.idicatorMaxHeight
            }
        }
        .onAppear {
            if selectedItem == currentItem {
                indicatorHeight = SidebarItemView.idicatorMaxHeight
            }
        }
    }
}
