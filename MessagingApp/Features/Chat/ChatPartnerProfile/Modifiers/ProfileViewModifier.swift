//
//  ProfileViewModifier.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/29/25.
//

import SwiftUI

struct OptionButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                Circle().fill(.buttonBackground.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top)
            .padding(.bottom, 40)
    }
}

struct ProfileContentViewModifier: ViewModifier {
    @Binding var disableScroll: Bool
    @Binding var showOptions: Bool
    
    func body(content: Content) -> some View {
        content
            .scrollDisabled(disableScroll)
            .opacity(showOptions ? 0.3 : 1)
            .defaultScrollAnchor(.top)
            .tint(Color("ButtonColor"))
            .background(Color("PrimaryBackgroundColor"))
    }
}

struct ProfileBannerColorViewModifier: ViewModifier {
    let user: User
    @Binding var profileIconMidYPosition: CGFloat
    @Binding var viewMinYPosition: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .background(alignment: .top) {
                Color(hex: user.bannerColor)
                    .frame(height: profileIconMidYPosition - viewMinYPosition)
            }
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            viewMinYPosition = proxy.frame(in: .global).minY
                        }
                }
            }
    }
    
    var bannerHeight: CGFloat {
        profileIconMidYPosition - viewMinYPosition
    }
}

struct ProfileIconFrameReader: ViewModifier {
    @Binding var iconMidY: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            setProfileIconPosition(midHeight: proxy.frame(in: .global).midY)
                        }
                }
            }
    }
    
    func setProfileIconPosition(midHeight: CGFloat) {
        iconMidY = midHeight
    }
}

struct ProfileOnlineStatusViewModifier: ViewModifier {
    let user: User
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                OnlineStatusCircle(
                    status: user.onlineStatus.rawValue,
                    color: Color("PrimaryBackgroundColor"),
                    outterDimension: .init(width: 26, height: 26),
                    innerDimension: .init(width: 20, height: 20)
                )
                .offset(x: -3, y: -1)
            }
            .padding(.bottom, 10)
    }
}

