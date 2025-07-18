//
//  MentionView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/16/25.
//
import SwiftUI

struct MentionView: View {
    @Binding var showMention: Bool
    let users: [User]
    let clickedBackgroundColor = Color("ButtonClickedBackgroundColor")
    @State private var buttonClicked = false
    
    func action() {
        showMention = false
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
    let onSelect: () -> Void
    @State private var isPressed = false
    
    var body: some View {
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
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onSelect()
            }
        }
        .onLongPressGesture(perform: {
            isPressed = true
        }, onPressingChanged: { newValue in
            if newValue == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    onSelect()
                }
            }
        })
        .animation(.easeOut(duration: 0.2), value: isPressed)
    }
}


struct MentionViewAnimation<Content: View>: View {
    let numUsersToShow: Int
    var isMentionVisible: Binding<Bool>
    var showMention: Bool
    let content: Content
    
    @State private var currentValue: CGFloat = 0
    let maxDisplayUsers: CGFloat = 5
    let maxHeight: CGFloat = 300
    
    init(numUsersToShow: Int, isMentionVisible: Binding<Bool>, showMention: Bool, content: () -> Content) {
        self.numUsersToShow = numUsersToShow
        self.isMentionVisible = isMentionVisible
        self.showMention = showMention
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(height: currentValue)
            .offset(y: -currentValue)
            .onAppear {
                let targetHeight = CGFloat((maxHeight / maxDisplayUsers)) * CGFloat(numUsersToShow)
                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.75)) {
                    currentValue = numUsersToShow >= 5 ? maxHeight : targetHeight
                }
            }
            .onChange(of: showMention) { newValue in
                if newValue == false {
                    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.75)) {
                        currentValue = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.isMentionVisible.wrappedValue = false
                    }
                }
            }
            .onChange(of: numUsersToShow) { newValue in
                let targetHeight = CGFloat((maxHeight / maxDisplayUsers)) * CGFloat(newValue)
                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.75)) {
                    currentValue = newValue >= 5 ? maxHeight : targetHeight
                }
            }
    }
}
