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
    @State private var userToPresent: User?
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let text = message.text {
                
                if text.contains(linkRegexPattern) {
                    Button {
                        showSafari = true
                    } label: {
                        Text(text)
                            .foregroundStyle(.blue)
                    }
                    .padding(.bottom, 5)
                    .sheet(isPresented: $showSafari) {
                        if let url = URL(string: text) {
                            SafariView(url: url)
                        }
                    }
                    .task {
                        retrieveMetaDataFromURL(url: text)
                    }
                    
                    if showEmbeded {
                        organizeEmbededItems()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
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
                } else {
                    AttributedTextView(text: text, userViewModel: userViewModel) { userName in
                        if let user = userViewModel.fetchUserByUsername(name: userName) {
                            userToPresent = user
                        }
                    }
                }
            }
            if let images = message.images?.allObjects as? [ImageData], !images.isEmpty {
                GridImageView(imageData: images)
                    .padding(.top, 5)
            }
            if let files = message.files?.allObjects as? [FileData], !files.isEmpty {
                ForEach(files, id: \.self) { file in
                    if let name = file.name, let data = file.data {
                        EmbededFileLayoutView(name: name, data: data)
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
            VStack(alignment: .leading) {
                EmbededLinkLayoutView(embededTitle: $embededTitle, embededDescription: $embededDescription, embededImage: $embededImage, embededImageDimension: $embededImageDimension, linkEmbededViewDimension: $linkEmbededViewDimension)
            }
        } else {
            HStack(alignment: .center) {
                EmbededLinkLayoutView(embededTitle: $embededTitle, embededDescription: $embededDescription, embededImage: $embededImage, embededImageDimension: $embededImageDimension, linkEmbededViewDimension: $linkEmbededViewDimension)
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
            if substr.first == "@", let user = userViewModel.fetchUserByUsername(name: String(substr.dropFirst())), let displayName = user.displayName {
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


