//
//  MessageInputBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.fdsfsd
//

import SwiftUI
import SwiftUIX

enum Field {
    case textEditor
}

struct MessageInputBar: View {
    @Binding var updateScrolling: Bool
    @Binding var showFileAndImageSelector: Bool
    @State private var message = ""
    @State private var showSendButton = false
    @State private var showMention = false
    @State private var isMentionVisible = false
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
                        .frame(minHeight: iconDimension.height)
                        .fixedSize(horizontal: false, vertical: true)
                        .onChange(of: message) { newMessage in
                            matchUsers = searchUser(users: User.mockUser)
                            
                            if !matchUsers.isEmpty {
                                showMention = true
                                isMentionVisible = true
                            } else {
                                showMention = false
                            }
                            
                            if newMessage != "" {
                                showSendButton = true
                            } else {
                                showSendButton = false
                            }
                            updateScrolling = true
                        }
                        .focused($focusedField, equals: .textEditor)
                        .onChange(of: focusedField) { newValue in
                            if focusedField == .textEditor {
                                showFileAndImageSelector = false
                            }
                        }
                //#TODO: Remove suggestive texts on top of the keyboard when try to mention a user
                //                        .keyboardType(.alphabet)
                //                        .autocorrectionDisabled(message.first == "@")
                }
                // Instead of using vertical padding (top & bottom),
                // added it to the frame to prevent the TextEditor from resizing
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
            if isMentionVisible {
                MentionViewAnimation(
                    numUsersToShow: matchUsers.count,
                    isMentionVisible: $isMentionVisible,
                    showMention: showMention
                ) {
                    MentionView(showMention: $showMention, users: matchUsers)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
extension MessageInputBar {
    func searchUser(users: [User]) ->[User] {
        if message == "@" {
            return users
        }
        
        let nameToSearch = message.dropFirst().lowercased()

        let result = users.filter { user in
            user.userName.lowercased().contains(nameToSearch) ||
            user.displayName.lowercased().contains(nameToSearch)
        }
        
        return result
    }
}


