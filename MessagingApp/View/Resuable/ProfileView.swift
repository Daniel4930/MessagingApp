//
//  ProfileView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//

import SwiftUI

struct ProfileView: View {
    let user: UserInfo
    
    @State private var showOptions: Bool = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ScrollView {
            HStack(spacing: 0) {
                Spacer()
                Button {
                    showOptions.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 50, height: 50)
                        .contentShape(Rectangle())
                }
                .padding(.top)
                .padding(.bottom, 50)
                .popover(isPresented: $showOptions, attachmentAnchor: .point(.center), arrowEdge: .top) {
                    VStack(spacing: 0) {
                        Button(action: {}) {
                            Text("Invite to Server")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .contentShape(Rectangle())
                        
                        DividerView()
                        
                        Button(action: {}) {
                            Text("Copy Username")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .contentShape(Rectangle())
                        
                        DividerView()
                        
                        Button(action: {}) {
                            Text("Copy User ID")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .contentShape(Rectangle())
                        
                        DividerView(thickness: 5)
                        
                        Button(action: {
                            // your action here
                        }) {
                            Text("Ignore")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .contentShape(Rectangle())
                        
                        DividerView()
                        
                        Button(action: {}) {
                            Text("Block")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .foregroundColor(.red)
                        }
                        .contentShape(Rectangle())
                        
                        DividerView()
                        
                        Button(action: {}) {
                            Text("Report User Profile")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .foregroundColor(.red)
                        }
                        .contentShape(Rectangle())
                    }
                    .presentationCompactAdaptation(.popover)
                }
            }
            .overlay(alignment: .top) {
                LineIndicator()
            }
            
            VStack(alignment: .leading) {
                IconView(user: user, iconDimension: (width: 100, height: 100))
                    .overlay(alignment: .bottomTrailing) {
                        OnlineStatusCircle(
                            status: user.onlineStatus,
                            color: Color("PrimaryBackgroundColor"),
                            outterDimension: (width: 26, height: 26),
                            innerDimension: (width: 20, height: 20)
                        )
                        .offset(x: -3, y: -1)
                    }
                Text(user.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user.userName)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                let buttons = [
                    (symbol: "message.fill", text: "Message"),
                    (symbol: "person.fill.badge.plus", text: "Add friend")
                ]
                
                Spacer()
                
                ForEach(buttons, id: \.symbol) { symbol, text in
                    VStack {
                        Button {
                            
                        } label: {
                            Image(systemName: symbol)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color("ButtonBackgroundColor"))
                                )
                        }
                        Text(text)
                            .font(.subheadline)
                    }
                    Spacer()
                }
            }
            
            VStack(alignment: .leading) {
                Text("About Me")
                    .font(.subheadline)
                    .bold()
                    .padding(.bottom, 7)
                
                Text(user.aboutMe)
                    .padding(.bottom, 20)
                
                
                Text("Member Since")
                    .font(.subheadline)
                    .bold()
                    .padding(.bottom, 4)
                Text(user.registeredDate)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("SecondaryBackgroundColor"))
            )
        }
        .opacity(showOptions ? 0.3 : 1)
        .defaultScrollAnchor(.top)
        .tint(Color("ButtonColor"))
        .padding()
        .background(Color("PrimaryBackgroundColor"))
    }
}
