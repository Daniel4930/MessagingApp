//
//  MessageInputBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.fdsfsd
//

import SwiftUI

struct MessageInputBar: View {
    @Binding var showFileAndImageSelector: Bool
    @Binding var scrollToBottom: Bool
    
    @State private var showSendButton = false
    @State private var showMention = false
    @State private var matchUsers: [User] = []
    @State private var dynamicHeight: CGFloat = UIScreen.main.bounds.height / 20
    @State private var uiTextView: UITextView = UITextView()
    @FocusState private var focusedField: Bool
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (25, 25)
    let horizontalPaddingSpace: CGFloat = 10
    let maxHeight = UIScreen.main.bounds.height / 5
    
    var body: some View {
        HStack(spacing: 10) {
            DisplaySelectorButton(showFileAndImageSelector: $showFileAndImageSelector, textEditorFocusedField: $focusedField)
            
            ZStack(alignment: .leading) {
                CustomTextEdior(dynamicHeight: $dynamicHeight, uiTextView: $uiTextView) {
                    showSendButton = !uiTextView.text.isEmpty
                    
                    let matched = searchUser(users: userViewModel.fetchAllUsers())
                    matchUsers = matched
                    showMention = !matched.isEmpty
                }
                .frame(height: min(dynamicHeight, maxHeight))
                .padding(.horizontal, horizontalPaddingSpace)
                .focused($focusedField)
                .onChange(of: focusedField) { _, newValue in
                    if focusedField {
                        showFileAndImageSelector = false
                    }
                }
                
                if let friends = userViewModel.user?.friends?.allObjects as? [User],
                   let friend = friends.first,
                   let displayName = friend.displayName,
                   uiTextView.text == ""
                {
                    Text("Message @\(displayName)")
                        .padding(.horizontal)
                        .foregroundStyle(.gray)
                }
            }
            .background(Color("SecondaryBackgroundColor"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            if showSendButton {
                Button {
                    messageViewModel.addMessage(
                        userId: userViewModel.user!.id!,
                        text: uiTextView.text,
                        imageData: nil,
                        files: nil,
                        location: .dm,
                        reaction: nil,
                        replyMessageId: nil,
                        forwardMessageId: nil,
                        edited: false
                    )
                    uiTextView.text = ""
                    scrollToBottom = true
                } label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .rotationEffect(Angle(degrees: 45))
                        .frame(width: iconDimension.width, height: iconDimension.height)
                        .padding(horizontalPaddingSpace)
                        .background(.blue)
                        .clipShape(.circle)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .overlay(alignment: .top) {
            MentionViewAnimation(numUsersToShow: matchUsers.count, showMention: $showMention) {
                MentionView(message: $uiTextView.text, showMention: $showMention, users: matchUsers)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(Color("PrimaryBackgroundColor"))
    }
}
extension MessageInputBar {
    func searchUser(users: [User]) -> [User] {
        
        if let message = uiTextView.text {
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
                if let displayName = user.displayName, let userName = user.userName {
                    return userName.lowercased().contains(nameToSearch) || displayName.lowercased().contains(nameToSearch)
                }
                return false
            }
        }
        return []
    }
}

struct CustomTextEdior: UIViewRepresentable {
    @Binding var dynamicHeight: CGFloat
    @Binding var uiTextView: UITextView
    var onMessageChange: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor(named: "SecondaryBackgroundColor")
        DispatchQueue.main.async {
            uiTextView = textView
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            let fittingSize = CGSize(width: uiView.bounds.width, height: .greatestFiniteMagnitude)
            let newSize = uiView.sizeThatFits(fittingSize)
            dynamicHeight = newSize.height
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEdior
        
        init(_ parent: CustomTextEdior) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let fittingSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
            let newSize = textView.sizeThatFits(fittingSize)
            parent.dynamicHeight = newSize.height
            
            parent.onMessageChange()
        }
    }
}
