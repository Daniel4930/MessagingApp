//
//  ProfileTopBarButtonView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/3/25.
//

import SwiftUI

struct ButtonInfo: Identifiable {
    let id = UUID()
    let systemImage: String
    let action: () -> Void
    
    enum PresentationStyle {
        case popover
        case sheet
        case noPresentaion
    }
}

struct ProfileTopBarButtonView: View {
    let buttons: [ButtonInfo]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(buttons) { buttonInfo in
                Spacer()
                button(buttonInfo: buttonInfo)
            }
        }
    }
}
extension ProfileTopBarButtonView {
    func button(buttonInfo: ButtonInfo) -> some View {
        Button {
            buttonInfo.action()
        } label: {
            Image(systemName: buttonInfo.systemImage)
                .frame(width: 35, height: 35)
                .contentShape(Rectangle())
        }
        .background {
            Circle().fill(.buttonBackground.opacity(0.8))
        }
        .padding(.top)
        .padding(.bottom, 40)
        .modifier(TapGestureAnimation())
    }
}
