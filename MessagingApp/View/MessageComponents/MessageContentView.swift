//
//  MessageContentView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/11/25.
//

import SwiftUI
import UIKit

struct MessageContentView: View {
    let message: Message
    
    let linkRegexPattern = /http(s)?:\/\/(www\.)?.+..+(\/.+)*/
    let linkMetadataService = LinkMetadataService()
    @State private var embededTitle = ""
    @State private var embededDescription = ""
    @State private var embededImage: UIImage?
    @State private var showEmbeded: Bool = false
    @State private var showSafari: Bool = false
    @State private var embededImageDimension: (width: CGFloat, height: CGFloat) = (0, 0)
    @State private var linkEmbededViewDimension: (width: CGFloat, height: CGFloat) = (0, 0)
    @State private var userToPresent: UserInfo?
    @State private var customTextViewHeight: CGFloat = .zero
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let text = message.text {
                AttributedTextView(text: text, userViewModel: userViewModel, customTextViewHeight: $customTextViewHeight, showSafari: $showSafari) { userName in
                    if let user = userViewModel.fetchUserByUsername(name: userName) {
                        userToPresent = user
                    }
                }
                .frame(height: customTextViewHeight)
                .sheet(isPresented: $showSafari) {
                    if let url = URL(string: text) {
                        SafariView(url: url)
                    }
                }
                .task {
                    if text.contains(linkRegexPattern) {
                        retrieveMetaDataFromURL(url: text)
                    }
                }

                if showEmbeded {
                    organizeEmbededItems()
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
            if let urls = message.images?.allObjects as? [ImageUrl], !urls.isEmpty {
                GridImageView(imageUrl: urls)
                    .padding(.top, 5)
            }
            if let urls = message.files?.allObjects as? [FileUrl], !urls.isEmpty {
                ForEach(urls, id: \.self) { fileUrl in
                    if let url = fileUrl.url {
                        EmbededFileLayoutView(url: url)
                    }
                }
            }
        }
        .sheet(item: $userToPresent) { user in
            ProfileView(user: user)
                .presentationDetents([.fraction(0.95)])
        }
    }
}
extension MessageContentView {
    func retrieveMetaDataFromURL(url: String) {
        linkMetadataService.getMetaDataFromUrl(urlString: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    embededTitle = response.title ?? ""
                    embededDescription = response.description ?? ""
                    embededImage = response.image
                    showEmbeded = true
                case .failure(let error):
                    print("Error: Can't retrieve website meta data \(error)")
                }
            }
        }
    }
    
    @ViewBuilder func organizeEmbededItems() -> some View {
        if embededImageDimension.width > embededImageDimension.height {
            VStack(alignment: .center) {
                EmbededLinkLayoutView(embededTitle: embededTitle, embededDescription: embededDescription, embededImage: embededImage, embededImageDimension: $embededImageDimension)
            }
        } else {
            HStack(alignment: .center) {
                EmbededLinkLayoutView(embededTitle: embededTitle, embededDescription: embededDescription, embededImage: embededImage, embededImageDimension: $embededImageDimension)
            }
        }
    }
    
    func separateMentionedNameAndMessage(text: String) -> [String] {
        var result: [String] = []
        
        var string: String = ""
        for subString in text.components(separatedBy: " ") {
            if let firstCharacter = subString.first, firstCharacter == "@" {
                if !string.isEmpty {
                    result.append(string)
                    string = ""
                }
                result.append(subString)
            } else {
                string.append(subString + " ")
            }
        }
        if !string.isEmpty {
            result.append(string)
        }
        
        //Remove extract space at the end if there is any
        result = result.map { $0.last == " " ? String($0.dropLast()) : $0 }
        
        return result
    }
    
    func styleMessage(_ text: String) -> AttributedString {
        var attributedString = AttributedString()
        
        for (index, substr) in separateMentionedNameAndMessage(text: text).enumerated() {
            var attributedSubstring = AttributedString()
            if substr.first == "@", let user = userViewModel.fetchUserByUsername(name: String(substr.dropFirst())) {
                let displayName = user.displayName
                var tempAttributedString = AttributedString("@\(displayName)")
                tempAttributedString.font = Font.system(.body).bold()
                tempAttributedString.backgroundColor = .blue.opacity(0.5)
                attributedSubstring.append(tempAttributedString)
                attributedSubstring.append(AttributedString(" "))
            } else {
                if index == 0 {
                    attributedSubstring.append(AttributedString("\(substr) "))
                } else {
                    attributedString.append(AttributedString("\(substr) "))
                }
            }
            attributedString.append(attributedSubstring)
        }
        
        return attributedString
    }
}


