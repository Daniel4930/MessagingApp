//
//  UserConversationView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//
import SwiftUI

struct UserConversationView: View {
    @Binding var updateScrolling: Bool
    let user: User
    let messages: [Message]
    let time: Date
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (45, 45)
    static let messageTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy, hh:mm a"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top) {
            Image(user.icon)
                .resizable()
                .frame(width: iconDimension.width, height: iconDimension.height)
                .clipShape(.circle)
            VStack(alignment: .leading) {
                HStack {
                    Text(user.name)
                        .font(.title3)
                        .bold()
                    Text(UserConversationView.messageTimeFormatter.string(from: time))
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                ForEach(messages) { message in
                    MessageView(message: message, updateScrolling: $updateScrolling)
                }
            }
        }
        .padding(.horizontal, 13)
        .padding(.bottom)
    }
}
