//
//  MessageInputBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.fdsfsd
//

import SwiftUI

enum Field {
    case textEditor
}

struct MessageInputBar: View {
    @Binding var updateScrolling: Bool
    @Binding var showFileAndImageSelector: Bool
    @State private var message = ""
    @State private var showSendButton = false
    @State private var showMention = false
    @State private var matchUsers: [User] = []
    @FocusState private var focusedField: Field?
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (25, 25)
    let paddingSpace: CGFloat = 10
    
    var body: some View {
        HStack(spacing: 10) {
            DisplaySelectorButton(showFileAndImageSelector: $showFileAndImageSelector, updateScrolling: $updateScrolling)
            
            ZStack(alignment: .leading) {
                if message == "" {
                    Text("Message @Clyde")
                        .padding(.horizontal)
                        .foregroundStyle(.gray)
                }
                HStack {
                    TextEditor(text: $message)
                        .scrollContentBackground(.hidden)
                        .onChange(of: message) { newMessage in
                            updateScrolling = true
                            
                            if newMessage != "" {
                                showSendButton = true
                            } else {
                                showSendButton = false
                            }
                            
                            matchUsers = searchUser(users: User.mockUser)
                            if !matchUsers.isEmpty {
                                showMention = true
                            } else {
                                showMention = false
                            }
                        }
                        .focused($focusedField, equals: .textEditor)
                        .onChange(of: focusedField) { newValue in
                            if focusedField == .textEditor {
                                showFileAndImageSelector = false
                            }
                        }
//                        .keyboardType(.alphabet)
//                        .autocorrectionDisabled(message.first == "@")
                }
                .frame(
                    minHeight: iconDimension.height + (paddingSpace * 2),
                    maxHeight: UIScreen.main.bounds.height / 5
                )
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, paddingSpace)
            }
            .background(Color("SecondaryBackgroundColor"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            if showSendButton {
                Button {
                    
                } label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .rotationEffect(Angle(degrees: 45))
                        .frame(width: iconDimension.width, height: iconDimension.height)
                        .padding(paddingSpace)
                        .background(.blue)
                        .clipShape(.circle)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .overlay(alignment: .top) {
            MentionViewAnimation(
                numUsersToShow: matchUsers.count,
                showMention: $showMention
            ) {
                MentionView(message: $message, showMention: $showMention, users: matchUsers)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
extension MessageInputBar {
    func searchUser(users: [User]) -> [User] {
        //message = "@"
        guard let commandIndex = message.lastIndex(of: "@") else { return [] }
        if commandIndex == message.startIndex {
            return users
        }
        
        //message = "text@text"
        guard let spaceIndex = message.lastIndex(of: " ") else { return [] }
        
        //message = "text@ " && message = "text @ "
        guard message.distance(from: spaceIndex, to: commandIndex) == 1 else { return [] }
        
        //message = "text @"
        if message[commandIndex] == message.last {
            return users
        }
        
        //message = "text @name"
        let nameToSearch = String(message[commandIndex...]).dropFirst().lowercased()
        
        return users.filter { user in
            user.userName.lowercased().contains(nameToSearch) ||
            user.displayName.lowercased().contains(nameToSearch)
        }
    }
}
