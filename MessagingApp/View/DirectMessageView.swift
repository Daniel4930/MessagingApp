//
//  DirectMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

struct DirectMessageView: View {
    @State var scrollToBottom: Bool = false
    @State var showFileAndImageSelector = false
    @State var keyboardHeight: CGFloat = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            MessageScrollView(scrollToBottom: $scrollToBottom)
            
            MessageInputBar(showFileAndImageSelector: $showFileAndImageSelector, scrollToBottom: $scrollToBottom)
            
            if showFileAndImageSelector {
                SelectorView(height: keyboardHeight)
            }
        }
        .modifier(KeyboardHeightProvider(height: $keyboardHeight))
        .background(Color("PrimaryBackgroundColor"))
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            hideKeyboard()
        }
        .toolbar {
            NavigationTopBar()
        }
        .tint(.white)
    }
}

struct DirectMessageDate: View {
    let date: Date
    let dividerLineThickness: CGFloat = 0.5
    
    static let dateHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(.gray)
                .frame(height: dividerLineThickness)
            Text(DirectMessageDate.dateHeaderFormatter.string(from: date))
                .foregroundStyle(.gray)
                .fontWeight(.bold)
                .font(.footnote)
                .padding(.horizontal, 8)
            Rectangle()
                .fill(.gray)
                .frame(height: dividerLineThickness)
        }
    }
}
