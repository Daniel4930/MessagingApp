//
//  MessageContentView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/11/25.
//

import SwiftUI
import UIKit
import FirebaseStorage
import Photos

struct MessageContentView: View {
    let message: Message
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @FocusState.Binding var focusedField: Field?

    @StateObject private var viewModel = MessageContentViewModel()
    @State private var showSafari = false
    @State private var embededImageDimension: CGSize = .zero
    @State private var linkEmbededViewDimension: CGSize = .zero
    @State private var customTextViewHeight: CGFloat = .zero
    @State private var showMessageOptions = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            customTextView
            
            embededView
            
            attachmentView
        }
        .onLongPressGesture(perform: longPressAction)
        .sheet(isPresented: $showMessageOptions) {
            EditMessageView(message: message, messageComposerViewModel: messageComposerViewModel)
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: View components
extension MessageContentView {
    @ViewBuilder var customTextView: some View {
        if let text = message.text {
            AttributedTextView(
                text: text,
                isPending: message.isPending,
                customTextViewHeight: $customTextViewHeight,
                showSafari: $showSafari,
                showMessageOptions: $showMessageOptions,
                isEdited: message.edited,
                editing: messageComposerViewModel.editedMessageId == message.id,
                onMentionTap: displayUserProfile(userName:)
            )
            .frame(height: customTextViewHeight)
            .sheet(isPresented: $showSafari) {
                if let url = URL(string: text) {
                    SafariView(url: url)
                }
            }
            .task { viewModel.retrieveLinkData(text: text) }
        }
    }
    
    @ViewBuilder var embededView: some View {
        if viewModel.showEmbeded {
            organizeEmbededItems
                .overlay(alignment: .leading) {
                    Color.gray
                        .frame(width: linkEmbededViewDimension.width * 0.015)
                }
                .background(
                    GeometryReader { proxy in
                        Color("SecondaryBackgroundColor")
                            .onAppear {
                                linkEmbededViewDimension.width = proxy.size.width
                                linkEmbededViewDimension.height = proxy.size.height
                            }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    @ViewBuilder var organizeEmbededItems: some View {
        if embededImageDimension.width > embededImageDimension.height {
            VStack(alignment: .center) {
                EmbededLinkLayoutView(embededTitle: viewModel.embededTitle, embededDescription: viewModel.embededDescription, embededImage: viewModel.embededImage, embededImageDimension: $embededImageDimension)
            }
        } else {
            HStack(alignment: .center) {
                EmbededLinkLayoutView(embededTitle: viewModel.embededTitle, embededDescription: viewModel.embededDescription, embededImage: viewModel.embededImage, embededImageDimension: $embededImageDimension)
            }
        }
    }
    
    @ViewBuilder var attachmentView: some View {
        if let attachmentFromMessage {
            GridImageView(
                imageUrls: attachmentFromMessage.photoUrls,
                selectedImages: attachmentFromMessage.selectedAttachments,
                dimensions: message.photoDimensions
            )

            VideoView(
                videoUrls: attachmentFromMessage.videoUrls,
                selectedAttachment: attachmentFromMessage.selectedAttachments,
                dimensions: message.videoDimensions
            )

            GridFilesView(
                files: attachmentFromMessage.files,
                selectedAttachment: attachmentFromMessage.selectedAttachments
            )
        }
    }
}

// MARK: View actions
extension MessageContentView {
    func displayUserProfile(userName: String) {
        if let user = userViewModel.fetchUserByUsername(name: userName, friends: friendViewModel.friends) {
            messageComposerViewModel.userProfile = user
        }
    }
    
    func longPressAction() {
        showMessageOptions.toggle()
        focusedField = nil
    }
}

// MARK: View properties
extension MessageContentView {
    var attachmentFromMessage: Attachment? {
        var result: Attachment = Attachment(selectedAttachments: [], photoUrls: [], videoUrls: [], files: [])
                
        if let selectionData = message.selectionData, !selectionData.isEmpty {
            result.selectedAttachments = viewModel.findAttachments(attachmentData: selectionData)
        } else {
            result.photoUrls = viewModel.getPhotoUrls(message: message)
            result.videoUrls = viewModel.getVideoUrls(message: message)
            result.files = viewModel.getFileUrls(message: message)
        }
        
        if result.photoUrls.isEmpty && result.videoUrls.isEmpty && result.files.isEmpty && result.selectedAttachments.isEmpty {
            return nil
        }
        return result
    }
}
