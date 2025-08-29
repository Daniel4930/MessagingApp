//
//  UserIconView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/16/25.
//
import SwiftUI
import Kingfisher

struct UserIconView: View {
    let user: User
    let iconDimension: CGSize
    let borderColor: Color
    let borderWidth: CGFloat
    
    // We can now remove the unused userViewModel
    // @EnvironmentObject var userViewModel: UserViewModel
    
    // Add a state to handle loading failures
    @State private var didFail = false
    
    init(user: User, iconDimension: CGSize = CGSize(width: 37, height: 37), borderColor: Color = .buttonBackground, borderWidth: CGFloat = 2) {
        self.user = user
        self.iconDimension = iconDimension
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    var body: some View {
        if didFail {
            Image(systemName: "person.circle")
                .iconStyle(iconDimension, borderColor: borderColor, borderWidth: borderWidth)
        } else {
            KFImage(URL(string: user.icon))
                .placeholder {
                    ProgressView()
                        .frame(width: iconDimension.width, height: iconDimension.height)
                        .clipShape(.circle)
                }
                .onFailure { _ in
                    didFail = true
                }
                .resizable()
                .cancelOnDisappear(true)
                .iconStyle(iconDimension, borderColor: borderColor, borderWidth: borderWidth)
        }
    }
}


struct OnlineStatusCircle: View {
    let status: String?
    let color: Color
    let outterCircleDimension: CGSize
    let innerCircleDimension: CGSize
    
    init(status: String?, color: Color, outterDimension: CGSize = .init(width: 15, height: 15), innerDimension: CGSize = .init(width: 11, height: 11)) {
        self.status = status
        self.color = color
        self.outterCircleDimension = outterDimension
        self.innerCircleDimension = innerDimension
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: outterCircleDimension.width, height: outterCircleDimension.height)
                .overlay {
                    if status == "online" {
                        Circle()
                            .fill(.green)
                            .frame(width: innerCircleDimension.width, height: innerCircleDimension.height)
                    }
                    else if status == "offline" {
                        let blackDotDimension: CGSize = .init(width: innerCircleDimension.width * 0.545, height: innerCircleDimension.height * 0.545)
                        Circle()
                            .fill(.gray)
                            .frame(width: innerCircleDimension.width, height: innerCircleDimension.height)
                            .overlay {
                                Circle()
                                    .fill(color)
                                    .frame(width: blackDotDimension.width, height: blackDotDimension.height)
                            }
                    }
                    else if status == "invisible" {
                        let blackDotDimension: CGSize = .init(width: innerCircleDimension.width * 0.545, height: innerCircleDimension.height * 0.545)
                        Circle()
                            .fill(.gray)
                            .frame(width: innerCircleDimension.width, height: innerCircleDimension.height)
                            .overlay {
                                Circle()
                                    .fill(color)
                                    .frame(width: blackDotDimension.width, height: blackDotDimension.height)
                            }
                    }
                    else if status == "doNotDisturb" {
                        let rectangleDimension: CGSize = .init(width: innerCircleDimension.width * 0.727, height: innerCircleDimension.height * 0.272)
                        Circle()
                            .fill(.red)
                            .frame(width: innerCircleDimension.width, height: innerCircleDimension.height)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(color)
                                    .frame(width: rectangleDimension.width, height: rectangleDimension.height)
                            }
                    }
                    else if status == "idle" {
                        let circleOverlayDimension: CGSize = .init(width: innerCircleDimension.width * 0.727, height: innerCircleDimension.height * 0.727)
                        Circle()
                            .fill(.yellow)
                            .frame(width: innerCircleDimension.width, height: innerCircleDimension.height)
                            .overlay {
                                Circle()
                                    .fill(color)
                                    .frame(width: circleOverlayDimension.width, height: circleOverlayDimension.height)
                                    .offset(x: -2, y: -2)
                            }
                    }
                }
        }
    }
}
