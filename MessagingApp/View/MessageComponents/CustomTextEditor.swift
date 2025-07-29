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
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    let maxHeight = UIScreen.main.bounds.height / 5
    let horizontalPaddingSpace: CGFloat = 10
    
    var body: some View {
        ZStack(alignment: .leading) {
            CustomUITextView(dynamicHeight: $dynamicHeight, uiTextView: $uiTextView) {
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
            }
            
            if message.contains(" ") {
                //message = "text@text"
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
                return user.userName!.lowercased().contains(nameToSearch) || user.displayName!.lowercased().contains(nameToSearch)
            }
        } else {
            return []
        }
    }
}

struct CustomUITextView: UIViewRepresentable {
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
        var parent: CustomUITextView
        
        init(_ parent: CustomUITextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 16)
            ]
            textView.typingAttributes = normalAttributes
            
            let fittingSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
            let newSize = textView.sizeThatFits(fittingSize)
            parent.dynamicHeight = newSize.height
            
            parent.onMessageChange()
        }
    }
}
