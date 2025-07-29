//
//  MessagingBarLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.fdsfsd
//

import SwiftUI

struct MessagingBarLayoutView: View {
    @Binding var showFileAndImageSelector: Bool
    @Binding var scrollToBottom: Bool
    @FocusState.Binding var focusedField: Field?
    
    @State private var showSendButton = false
    @State private var showMention = false
    @State private var matchUsers: [User] = []
    @State private var dynamicHeight: CGFloat = UIScreen.main.bounds.height / 20
    @State private var uiTextView: UITextView = UITextView()
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (25, 25)
    let horizontalPaddingSpace: CGFloat = 10
    
    var body: some View {
        HStack(spacing: 10) {
            SelectorButtonLayoutView(showFileAndImageSelector: $showFileAndImageSelector, focusedField: $focusedField)
            
            CustomTextEditor(
                uiTextView: $uiTextView,
                dynamicHeight: $dynamicHeight,
                showSendButton: $showSendButton,
                matchUsers: $matchUsers,
                showMention: $showMention,
                focusedField: $focusedField
            )
            
            if showSendButton {
                Button {
                    messageViewModel.addMessage(
                        userId: userViewModel.user!.id!,
                        text: removeExtraEndSpace(),
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
                    showSendButton = false
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
            MentionLayoutViewAnimation(numUsersToShow: matchUsers.count, showMention: $showMention) {
                MentionLayoutView(users: matchUsers) { name in
                    uiTextView.text.removeLast() // remove "@"
                    
                    let mutableAttString = NSMutableAttributedString(attributedString: uiTextView.attributedText)
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor(named: "MentionNameColor") ?? UIColor(Color(hex: "#d4c7ff")),
                        .font: UIFont.systemFont(ofSize: 16, weight: .bold)
                    ]
                    
                    let attributedString = NSAttributedString(string: "@" + name + " ", attributes: attributes)
                    mutableAttString.append(attributedString)
                    
                    let normalAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.label,
                        .font: UIFont.systemFont(ofSize: 16)
                    ]
                    
                    uiTextView.attributedText = mutableAttString
                    uiTextView.typingAttributes = normalAttributes
                    
                    showMention = false
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color("PrimaryBackgroundColor"))
    }
}
extension MessagingBarLayoutView {
    func removeExtraEndSpace() -> String {
        if uiTextView.text.last == " " {
            return String(uiTextView.text.dropLast())
        }
        return uiTextView.text
    }
}
