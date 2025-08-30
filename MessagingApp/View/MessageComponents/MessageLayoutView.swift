//
//  UserConversationView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//
import SwiftUI

struct MessageLayoutView: View {
    let user: User
    let messages: [Message]
    let time: Date
    
    let iconDimension: CGSize = .init(width: 45, height: 45)
    static let messageTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy, hh:mm a"
        formatter.timeZone = .current
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top) {
            UserIconView(user: user, iconDimension: iconDimension)
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(user.displayName.isEmpty ? user.userName : user.displayName)
                        .font(.title3)
                        .bold()
                    Text(MessageLayoutView.messageTimeFormatter.string(from: time))
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                ForEach(messages) { message in
                    MessageContentView(message: message)
                }
            }
        }
        .padding(.horizontal, 13)
        .padding(.bottom)
    }
}
