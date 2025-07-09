//
//  DirectMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

struct User {
    let name: String
    let icon: String
    let messages: [String]
}

struct DirectMessageView: View {
    let mockData = [
        User(name: "Clyde", icon: "icon", messages: ["Hi", "How are you"]),
        User(name: "Phu", icon: "icon", messages: ["I'm fine", "So far so good and I'm glad everything work out", "So far so good", "So far so good"])
    ]
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(.gray)
                .frame(height: 0.4)
                .ignoresSafeArea(edges: .horizontal)
                .padding(.top, 10)
            ScrollView {
                ForEach(Array(mockData.enumerated()), id: \.offset) { index, user in
                    VStack(alignment: .leading) {
                        ZStack {
                            Rectangle()
                                .fill(.gray)
                                .frame(height: 0.5)
                            Text("October 2, 2024")
                                .padding(.horizontal, 8)
                                .background(.black)
                                .foregroundStyle(.gray)
                                .fontWeight(.bold)
                                .font(.footnote)
                        }
                        .padding(.horizontal, 7)
                        HStack(alignment: .top) {
                            Image(user.icon)
                                .resizable()
                                .frame(width: 45, height: 45)
                                .clipShape(.circle)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(user.name)
                                        .font(.title3)
                                        .bold()
                                    Text("7/4/24, 04:26")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                }
                                ForEach(Array(user.messages.enumerated()), id: \.offset) { _, message in
                                    VStack {
                                        Text(message)
                                    }
                                }
                            }
                        }
                        .padding(.leading, 13)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                DirectMessageNavbar(data: mockData[0])
            }
        }
        .tint(.white)
    }
}

struct DirectMessageNavbar: View {
    let data: User
    let backButtonWidth: CGFloat = 19
    let iconDimension: (CGFloat, CGFloat) = (35, 35)
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
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
                .frame(width: iconDimension.0, height: iconDimension.1)
                .clipShape(.circle)
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .offset(x: 4, y: 2)
                        .fill(.black)
                        .frame(width: 15, height: 15)
                        .overlay {
                            Circle()
                                .offset(x: 4, y: 2)
                                .fill(.green)
                                .frame(width: 9, height: 9)
                        }
                }
                .padding(.trailing, 7)
            
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

//#Preview {
//    DirectMessageView()
//}
