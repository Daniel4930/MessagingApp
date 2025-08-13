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
    @ObservedObject var uploadDataViewModel: UploadDataViewModel
    
    @State private var showSendButton = false
    @State private var showMention = false
    @State private var matchUsers: [User] = []
    @State private var dynamicHeight: CGFloat = UIScreen.main.bounds.height / 20
    @State private var uiTextView: UITextView = UITextView()
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            SelectorButtonLayoutView(showFileAndImageSelector: $showFileAndImageSelector, focusedField: $focusedField)
            
            CustomTextEditor(
                uiTextView: $uiTextView,
                dynamicHeight: $dynamicHeight,
                showSendButton: $showSendButton,
                matchUsers: $matchUsers,
                showMention: $showMention,
                focusedField: $focusedField,
                scrollToBottom: $scrollToBottom
            )
            
            if showSendButton || !uploadDataViewModel.selectionData.isEmpty {
                Button {
                    messageViewModel.addMessage (
                        userId: userViewModel.user!.id!,
                        text: removeExtraEndSpace(),
                        images: uploadDataViewModel.selectionData == [] ? [] : convertUImageToImageData(),
                        files: nil,
                        location: .dm,
                        reaction: nil,
                        replyMessageId: nil,
                        forwardMessageId: nil,
                        edited: false
                    )
                    uiTextView.text = ""
                    uploadDataViewModel.selectionData = []
                    scrollToBottom = true
                    showSendButton = false
                } label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .rotationEffect(Angle(degrees: 45))
                        .frame(width: 25, height: 25)
                        .padding(10)
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
                    uiTextView.text.removeLast(uiTextView.text.distance(from: uiTextView.text.lastIndex(of: "@")!, to: uiTextView.text.endIndex))
                    uiTextView.text.append("@" + name + " ")
                    showMention = false
                    
                    if let delegate = uiTextView.delegate as? CustomUITextView.Coordinator {
                        delegate.textViewDidChange(uiTextView)
                    }
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
    
    func convertUImageToImageData() -> [Data?] {
        return uploadDataViewModel.selectionData.map { data in
            if let uiImage = data.data.photo?.image {
                return uiImage.pngData() ?? nil
            }
            return nil
        }
    }
}
