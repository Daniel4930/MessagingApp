//
//  CustomUITextView.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/29/25.
//

import SwiftUI

struct CustomUITextView: UIViewRepresentable {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    let memberIds: [String]
    var onMessageChange: () -> Void
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor(named: "SecondaryBackgroundColor")
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        DispatchQueue.main.async {
            messageComposerViewModel.uiTextEditor = textView
        }
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            let fittingSize = CGSize(width: uiView.bounds.width, height: .greatestFiniteMagnitude)
            let newSize = uiView.sizeThatFits(fittingSize)
            if self.messageComposerViewModel.customTextEditorHeight != newSize.height {
                self.messageComposerViewModel.customTextEditorHeight = newSize.height
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomUITextView
        private var cachedRegexPattern: String?
        private var cachedMemberIds: [String] = []
        private var cachedFriendsCount: Int = 0
        
        static let styledAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "MentionNameColor") ?? UIColor(Color(hex: "#d4c7ff")),
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
        static let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 16)
        ]

        init(_ parent: CustomUITextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if let user = parent.userViewModel.user, let text = textView.text {
                let mutableAttString = NSMutableAttributedString()
                
                do {
                    guard let pattern = generateNameMatchPattern(user: user) else { return }
                    let parts = try findMatchedParts(pattern: pattern, text: text)

                    for (index, part) in parts.enumerated() {
                        styleMentionedName(
                            mutableAttString: mutableAttString,
                            parts: parts,
                            index: index,
                            part: part
                        )
                    }
                    textView.attributedText = mutableAttString
                } catch {
                    print(error.localizedDescription)
                }
            }
            parent.onMessageChange()
        }
        
        private func generateNameMatchPattern(user: User) -> String? {
            let currentFriendsCount = parent.friendViewModel.friends.count

            // Only regenerate pattern if friends or members changed
            if cachedRegexPattern == nil || cachedMemberIds != parent.memberIds || cachedFriendsCount != currentFriendsCount {
                let userName = user.userName
                let displayName = user.displayName
                let friends = parent.friendViewModel.friends.filter({ parent.memberIds.contains($0.id!) })

                var pattern = "@(\(userName)\(displayName.isEmpty ? "" : "|\(displayName)")"

                for friend in friends {
                    if !friend.displayName.isEmpty {
                        pattern.append("|\(friend.displayName)|\(friend.userName)")
                    } else {
                        pattern.append("|\(friend.userName)")
                    }
                }
                pattern.append(")")

                cachedRegexPattern = pattern
                cachedMemberIds = parent.memberIds
                cachedFriendsCount = currentFriendsCount
            }

            return cachedRegexPattern
        }
        
        private func findMatchedParts(pattern: String, text: String) throws -> [String] {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsText = text as NSString
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            
            var parts: [String] = []
            var lastLocation = 0
            
            for match in matches {
                if match.range.location > lastLocation {
                    let segment = nsText.substring(with: NSRange(location: lastLocation, length: match.range.location - lastLocation))
                    if !segment.isEmpty {
                        parts.append(segment)
                    }
                }
                parts.append(nsText.substring(with: match.range))
                
                lastLocation = match.range.location + match.range.length
            }
            if lastLocation < nsText.length {
                parts.append(nsText.substring(with: NSRange(location: lastLocation, length: nsText.length - lastLocation)))
            }
            
            return parts
        }
        
        private func styleMentionedName(
            mutableAttString: NSMutableAttributedString,
            parts: [String],
            index: Int,
            part: String
        ) {
            if part.first == "@", let _ = parent.userViewModel.fetchUserByUsername(name: String(part.dropFirst()), friends: parent.friendViewModel.friends) {
                var finalAttributes: [NSAttributedString.Key: Any] = Coordinator.normalAttributes
                
                if index != 0 && index != parts.count - 1 {
                    if parts[index - 1].last == " " && parts[index + 1].first == " " {
                        finalAttributes = Coordinator.styledAttributes
                    }
                } else if index == 0 {
                    // Mention at start — only style if there's space after or it's end of text
                    if index + 1 >= parts.count || parts[index + 1].first == " " {
                        finalAttributes = Coordinator.styledAttributes
                    }
                } else if index == parts.count - 1 {
                    // Mention at end — only style if there's space before or it's start of text
                    if index - 1 < 0 || parts[index - 1].last == " " {
                        finalAttributes = Coordinator.styledAttributes
                    }
                }
                
                let attributedString = NSAttributedString(string: part, attributes: finalAttributes)
                mutableAttString.append(attributedString)
            }
            else {
                let attributedString = NSAttributedString(string: part, attributes: Coordinator.normalAttributes)
                mutableAttString.append(attributedString)
            }
        }
    }
}
