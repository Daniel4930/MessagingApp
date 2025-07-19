//
//  MentionView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/16/25.
//
import SwiftUI

struct MentionView: View {
    @Binding var message: String
    @Binding var showMention: Bool
    let users: [User]
    let clickedBackgroundColor = Color("ButtonClickedBackgroundColor")
    @State private var buttonClicked = false
    
    func action(name: String) {
        showMention = false
        $message.wrappedValue = "@" + name + " "
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(users) { user in
                    MentionButton(user: user, onSelect: action)
                    
                    if let lastUser = users.last, lastUser.id != user.id {
                        DividerView(padding: (Edge.Set.horizontal, 16))
                    }
                }
            }
        }
        .background(Color("SecondaryBackgroundColor"))
    }
}

struct MentionButton: View {
    let user: User
    let onSelect: (String) -> Void
    @State private var isPressed = false
    
    let animationDuration = 0.1
    let removeMentionViewDeadline = 0.2
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: animationDuration)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + removeMentionViewDeadline) {
                onSelect(user.displayName)
            }
        } label: {
            HStack {
                IconView(user: user, borderColor: Color("SecondaryBackgroundColor"))
                
                Text(user.displayName)
                    .bold()
                
                Spacer()
                
                Text(user.userName)
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(isPressed ? Color("ButtonClickedBackgroundColor") : Color("SecondaryBackgroundColor"))
        }
    }
}


struct MentionViewAnimation<Content: View>: View {
    let numUsersToShow: Int
    var showMention: Binding<Bool>
    let content: Content
    
    @State private var currentValue: CGFloat = 0
    let maxDisplayUsers: CGFloat = 5
    let maxHeight: CGFloat = 300
    let springStiffness = 0.5
    let springDrag = 0.75
    
    init(numUsersToShow: Int, showMention: Binding<Bool>, content: () -> Content) {
        self.numUsersToShow = numUsersToShow
        self.showMention = showMention
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(height: currentValue)
            .offset(y: -currentValue)
            .animation(.interactiveSpring(response: springStiffness, dampingFraction: springDrag), value: currentValue)
            .onChange(of: numUsersToShow) { newValue in
                if showMention.wrappedValue {
                    let targetHeight = CGFloat((maxHeight / maxDisplayUsers)) * CGFloat(newValue)
                    currentValue = newValue >= 5 ? maxHeight : targetHeight
                } else {
                    currentValue = 0
                }
            }
    }
}
