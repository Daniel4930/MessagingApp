//
//  MessageInputBars.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//
import SwiftUI

struct CustomTextEditor: View {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @FocusState.Binding var focusedField: Field?
    @Binding var scrollToBottom: Bool
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    
    let horizontalPaddingSpace: CGFloat = 10
    
    var body: some View {
        ZStack(alignment: .leading) {
            CustomUITextView(messageComposerViewModel: messageComposerViewModel, scrollToBottom: $scrollToBottom) {
                messageComposerViewModel.showSendButton = !messageComposerViewModel.uiTextView.text.isEmpty
                
                if let user = userViewModel.user {
                    var users = Array(arrayLiteral: user)
                    users.append(contentsOf: friendViewModel.friends)
                    let matched = searchUser(users: users)
                    messageComposerViewModel.mathchUsers = matched
                    messageComposerViewModel.showMention = !matched.isEmpty
                }
            }
            .frame(height: min(messageComposerViewModel.customTextEditorHeight, MessageComposerViewModel.customTextEditorMaxHeight))
            .padding(.horizontal, horizontalPaddingSpace)
            .focused($focusedField, equals: .textView)
            
            if let friend = friendViewModel.friends.first, messageComposerViewModel.uiTextView.text.isEmpty {
                let displayName = friend.displayName
                
                Text("Message @\(displayName)")
                    .padding(.horizontal)
                    .foregroundStyle(.gray)
            }
        }
        .background(Color("SecondaryBackgroundColor"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
extension CustomTextEditor {
    func searchUser(users: [UserInfo]) -> [UserInfo] {
        if let message = messageComposerViewModel.uiTextView.text {
            //message = "@"
            guard let commandIndex = message.lastIndex(of: "@") else { return [] }
            
            if message.count == 1 {
                return users
            }
            
            if commandIndex != message.startIndex {
                guard let spaceIndex = message.lastIndex(of: " ") else { return [] }
                //message = "text@ " && message = "text @ "
                guard message.distance(from: spaceIndex, to: commandIndex) == 1 else { return [] }
                
                //message = "text @"
                if message[commandIndex] == message.last {
                    return users
                }
            }
            
            //message = "text @name"
            let nameToSearch = String(message[commandIndex...]).dropFirst().lowercased()
            
            return users.filter { user in
                let userName = user.userName
                let displayName = user.displayName
                return userName.lowercased().contains(nameToSearch) || displayName.lowercased().contains(nameToSearch)
            }
        } else {
            return []
        }
    }
}

struct CustomUITextView: UIViewRepresentable {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var scrollToBottom: Bool
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
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        tapGesture.delegate = context.coordinator
        textView.addGestureRecognizer(tapGesture)
        DispatchQueue.main.async {
            messageComposerViewModel.uiTextView = textView
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {}
    
    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
        var parent: CustomUITextView
        
        init(_ parent: CustomUITextView) {
            self.parent = parent
        }
        
        private func generateNameMatchPattern(user: UserInfo) -> String? {
            let userName = user.userName
            let displayName = user.displayName
            let friends = parent.friendViewModel.friends
            
            var pattern = "@(\(userName)|\(displayName)"
            
            for friend in friends {
                if !friend.displayName.isEmpty {
                    pattern.append("|\(friend.displayName)|\(friend.userName)")
                } else {
                    pattern.append("|\(friend.userName)")
                }
            }
            pattern.append(")")
            
            return pattern
        }
        
        @objc func handleTap() {
            parent.scrollToBottom = true
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let mutableAttString = NSMutableAttributedString()
            let styledAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(named: "MentionNameColor") ?? UIColor(Color(hex: "#d4c7ff")),
                .font: UIFont.systemFont(ofSize: 16, weight: .bold)
            ]
            
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 16)
            ]
            
            if let user = parent.userViewModel.user, let text = textView.text {
                do {
                    guard let pattern = generateNameMatchPattern(user: user) else { return }
                    
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

                    for (index, part) in parts.enumerated() {
                        if part.first == "@", let _ = parent.userViewModel.fetchUserByUsername(name: String(part.dropFirst()), friends: parent.friendViewModel.friends) {
                            var finalAttributes: [NSAttributedString.Key: Any] = normalAttributes
                            
                            if index != 0 && index != parts.count - 1 {
                                if parts[index - 1].last == " " && parts[index + 1].first == " " {
                                    finalAttributes = styledAttributes
                                }
                            } else if index == 0 {
                                // Mention at start — only style if there's space after or it's end of text
                                if index + 1 >= parts.count || parts[index + 1].first == " " {
                                    finalAttributes = styledAttributes
                                }
                            } else if index == parts.count - 1 {
                                // Mention at end — only style if there's space before or it's start of text
                                if index - 1 < 0 || parts[index - 1].last == " " {
                                    finalAttributes = styledAttributes
                                }
                            }
                            
                            let attributedString = NSAttributedString(string: part, attributes: finalAttributes)
                            mutableAttString.append(attributedString)
                        }
                        else {
                            let attributedString = NSAttributedString(string: part, attributes: normalAttributes)
                            mutableAttString.append(attributedString)
                        }
                    }
                    textView.attributedText = mutableAttString
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            let fittingSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
            let newSize = textView.sizeThatFits(fittingSize)
            parent.messageComposerViewModel.customTextEditorHeight = newSize.height
            
            parent.onMessageChange()
        }
    }
}
