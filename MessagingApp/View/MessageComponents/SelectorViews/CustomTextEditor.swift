//
//  MessageInputBars.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//
import SwiftUI

struct CustomTextEditor: View {
    @Binding var uiTextView: UITextView
    @Binding var dynamicHeight: CGFloat
    @Binding var showSendButton: Bool
    @Binding var matchUsers: [User]
    @Binding var showMention: Bool
    @FocusState.Binding var focusedField: Field?
    @Binding var scrollToBottom: Bool
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    let maxHeight = UIScreen.main.bounds.height / 5
    let horizontalPaddingSpace: CGFloat = 10
    
    var body: some View {
        ZStack(alignment: .leading) {
            CustomUITextView(dynamicHeight: $dynamicHeight, uiTextView: $uiTextView, userViewModel: userViewModel, scrollToBottom: $scrollToBottom) {
                showSendButton = !uiTextView.text.isEmpty
                
                if let user = userViewModel.user, let friends = user.friends?.allObjects as? [User] {
                    var users = Array(arrayLiteral: user)
                    users.append(contentsOf: friends)
                    let matched = searchUser(users: users)
                    matchUsers = matched
                    showMention = !matched.isEmpty
                }
            }
            .frame(height: min(dynamicHeight, maxHeight))
            .padding(.horizontal, horizontalPaddingSpace)
            .focused($focusedField, equals: .textView)
            
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
    }
}
extension CustomTextEditor {
    func searchUser(users: [User]) -> [User] {
        if let message = uiTextView.text {
            //message = "@"
            guard let commandIndex = message.lastIndex(of: "@") else { return [] }
            if message.count == 1 && commandIndex == message.startIndex {
                return users
            } else {
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
                if let userName = user.userName, let displayName = user.displayName {
                    return userName.lowercased().contains(nameToSearch) || displayName.lowercased().contains(nameToSearch)
                }
                return false
            }
        } else {
            return []
        }
    }
}

struct CustomUITextView: UIViewRepresentable {
    @Binding var dynamicHeight: CGFloat
    @Binding var uiTextView: UITextView
    let userViewModel: UserViewModel
    @Binding var scrollToBottom: Bool
    var onMessageChange: () -> Void
    
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
    
    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
        var parent: CustomUITextView
        
        init(_ parent: CustomUITextView) {
            self.parent = parent
        }
        
        private func generateNameMatchPattern(user: User) -> String? {
            guard let userName = user.userName else { return nil }
            guard let displayName = user.displayName else { return nil }
            guard let friends = user.friends?.allObjects as? [User] else { return nil }
            
            var pattern = "@(\(userName)|\(displayName)"
            
            for friend in friends {
                if let displayName = friend.displayName, let userName = friend.userName {
                    pattern.append("|\(displayName)|\(userName)")
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
                        if part.first == "@", let _ = parent.userViewModel.fetchUserByUsername(name: String(part.dropFirst())) {
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
            parent.dynamicHeight = newSize.height
            
            parent.onMessageChange()
        }
    }
}
