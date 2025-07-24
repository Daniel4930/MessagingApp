//
//  IconView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/16/25.
//
import SwiftUI

struct IconView: View {
    let user: User?
    let iconDimension: (width: CGFloat, height: CGFloat)
    let iconBorderThickness: CGFloat = 41
    let borderColor: Color
    
    init(user: User?, iconDimension: (width: CGFloat, height: CGFloat) = (37, 37), borderColor: Color = Color("PrimaryBackgroundColor")) {
        self.user = user
        self.iconDimension = iconDimension
        self.borderColor = borderColor
    }
    
    var body: some View {
        ZStack {
            borderColor
                .frame(width: iconBorderThickness, height: iconBorderThickness)
                .clipShape(.circle)
            
            if let user = user, let data = user.icon, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconDimension.width, height: iconDimension.height)
                    .clipShape(.circle)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconDimension.width, height: iconDimension.height)
                    .clipShape(.circle)
            }
        }
    }
}

struct OnlineStatusCircle: View {
    let status: String?
    let color: Color
    let outterCircleDimension: (width: CGFloat, height: CGFloat)
    let innerCircleDimension: (width: CGFloat, height: CGFloat)
    
    init(status: String?, color: Color, outterDimension: (width: CGFloat, height: CGFloat) = (15, 15), innerDimension: (width: CGFloat, height: CGFloat) = (11, 11)) {
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
                        let blackDotDimension: (width: CGFloat, height: CGFloat) = (innerCircleDimension.width * 0.545, innerCircleDimension.height * 0.545)
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
                        let blackDotDimension: (width: CGFloat, height: CGFloat) = (innerCircleDimension.width * 0.545, innerCircleDimension.height * 0.545)
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
                        let rectangleDimension: (width: CGFloat, height: CGFloat) = (innerCircleDimension.width * 0.727, innerCircleDimension.height * 0.272)
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
                        let circleOverlayDimension: (width: CGFloat, height: CGFloat) = (innerCircleDimension.width * 0.727, innerCircleDimension.height * 0.727)
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
