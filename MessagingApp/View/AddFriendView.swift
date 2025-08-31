//
//  AddFriendView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/30/25.
//

import SwiftUI

struct AddFriendView: View {
    @Binding var showAddFriend: Bool
    @State private var username: String = ""
    @State private var usernameErrorMessage: String = ""
    @State private var alertMessage: String = ""
    @State private var alertMessageHeight: CGFloat = .zero
    @State private var alertBackgroundColor: Color = .clear
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
        
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
            VStack {
                ZStack {
                    Button {
                        hideKeyboard()
                        showAddFriend = false
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .tint(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Add Friends")
                        .bold()
                }
                .padding(.top)
                
                FormTextFieldView(
                    formType: .text,
                    formTitle: "Who would you like to add as a friend?",
                    textFieldTitle: "Enter a username",
                    errorMessage: $usernameErrorMessage,
                    text: $username
                )
                .padding(.vertical)
                
                Button {
                    usernameErrorMessage = ""
                    alertBackgroundColor = .clear
                    alertMessageHeight = .zero
                    alertMessage = ""
                    
                    if username.isEmpty {
                        usernameErrorMessage = "Username is empty"
                    }
                    
                    if usernameErrorMessage.isEmpty {
                        //TODO: Send friend request
                    }
                } label: {
                    Capsule()
                        .fill(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .overlay {
                            Text("Send Friend Request")
                                .foregroundStyle(.white)
                        }
                }
                Spacer()
            }
            .padding(.horizontal)
            .background(Color.primaryBackground)
        }
        .overlay(alignment: .top) {
            AlertMessageView(text: $alertMessage, height: $alertMessageHeight, backgroundColor: $alertBackgroundColor)
        }
    }
}
