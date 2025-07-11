//
//  DirectMessageTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI

struct DirectMessageTopBar: ToolbarContent {
    let data: User
    let backButtonWidth: CGFloat = 19
    let iconDimension: (width: CGFloat, height: CGFloat) = (40, 40)
    let statusCircleOffset: (x: CGFloat, y: CGFloat) = (2, 2)
    let outterCircleDimension: (width: CGFloat, height: CGFloat) = (18, 18)
    let innerCircleDimension: (width: CGFloat, height: CGFloat) = (11, 11)
    let iconPadding: CGFloat = 7
    
    @Environment(\.dismiss) var dismiss
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: backButtonWidth)
                    .bold()
            }
            HStack {
                Image(data.icon)
                    .resizable()
                    .frame(width: iconDimension.width, height: iconDimension.height)
                    .clipShape(.circle)
                    .overlay(alignment: .bottomTrailing) {
                        Circle()
                            .offset(x: statusCircleOffset.x, y: statusCircleOffset.y)
                            .fill(.black)
                            .frame(width: outterCircleDimension.width, height: outterCircleDimension.height)
                            .overlay {
                                Circle()
                                    .offset(x: statusCircleOffset.x, y: statusCircleOffset.y)
                                    .fill(.green)
                                    .frame(width: innerCircleDimension.width, height: innerCircleDimension.height)
                            }
                    }
                    .padding(.trailing, iconPadding)
                
                Text(data.name)
                    .font(.title3)
                    .bold()
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 5, height: 10)
                    .bold()
            }
        }
    }
}
