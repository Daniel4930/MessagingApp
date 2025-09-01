//
//  AttributedTextView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/11/25.
//

import SwiftUI
import UIKit

//TODO: Add an enum for action urls

struct AttributedTextView: UIViewRepresentable {
    let text: String
    @Binding var customTextViewHeight: CGFloat
    @Binding var showSafari: Bool
    let onMentionTap: (String) -> Void
    let linkRegexPattern = /http(s)?:\/\/(www\.)?.+..+(\/.+)*/
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.delegate = context.coordinator
        textView.dataDetectorTypes = []
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = .zero
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return textView
    }
    
    func updateUIView(_ uiTextView: UITextView, context: Context) {
        let baseFont = UIFont.systemFont(ofSize: 16)
        let baseColor = UIColor.white
        let attributed = NSMutableAttributedString()
        let words = text.split(separator: " ")
        
        for (index, word) in words.enumerated() {
            let wordString = String(word)
            
            if word.contains(linkRegexPattern), let url = URL(string: wordString) {
                let linkAttr = NSAttributedString(string: wordString, attributes: [
                    .link: url,
                    .foregroundColor: UIColor.blue,
                    .font: baseFont,
                    .underlineStyle: NSUnderlineStyle.single
                ])
                attributed.append(linkAttr)
            }
            
            else if word.hasPrefix("@"), let user = userViewModel.fetchUserByUsername(name: String(wordString.dropFirst()), friends: friendViewModel.friends),
                    let url = URL(string: "mention://\(user.userName)") {
                
                let name = user.displayName.isEmpty ? user.userName : user.displayName
                
                // Build mention string with '@' + name
                let mentionString = "@" + name
                
                // Create attributed string for mention
                let mentionAttr = NSMutableAttributedString(string: mentionString, attributes: [
                    .link: url,
                    .foregroundColor: UIColor.white,
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .backgroundColor: UIColor.blue.withAlphaComponent(0.3)
                ])
                
                // Append mention with styling
                attributed.append(mentionAttr)
            } else {
                // Normal word - add with base style
                let normalAttr = NSAttributedString(string: wordString, attributes: [
                    .foregroundColor: baseColor,
                    .font: baseFont
                ])
                attributed.append(normalAttr)
            }
            
            // Append a space after every word except last
            if index != words.count - 1 {
                attributed.append(NSAttributedString(string: " ", attributes: [
                    .foregroundColor: baseColor,
                    .font: baseFont
                ]))
            }
        }
        
        // Set to UITextView
        uiTextView.attributedText = attributed
        
        let size = uiTextView.sizeThatFits(CGSize(width: uiTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        if uiTextView.frame.height != size.height {
            DispatchQueue.main.async {
                customTextViewHeight = size.height
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AttributedTextView
        
        init(parent: AttributedTextView) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
            if case let .link(url) = textItem.content {
                if url.scheme == "mention" {
                    // Rebuild the full username including fragment if it exists
                    let userNameWithFragment: String
                    if let fragment = url.fragment, !fragment.isEmpty {
                        userNameWithFragment = "\(url.host ?? "")#\(fragment)"
                    } else {
                        userNameWithFragment = url.host ?? ""
                    }
                    
                    return UIAction(title: "Show Profile") { _ in
                        self.parent.onMentionTap(userNameWithFragment)
                    }
                }
                
                else if url.scheme == "https" || url.scheme == "http" {
                    return UIAction(title: "Show Link") { _ in
                        self.parent.showSafari = true
                    }
                }
            }
            return defaultAction
        }
    }
}
