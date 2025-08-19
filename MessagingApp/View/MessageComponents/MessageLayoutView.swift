//
//  UserConversationView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//
import SwiftUI

struct MessageLayoutView: View {
    let user: UserInfo
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
            let url = URL(string: user.icon)
            
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: iconDimension.width, height: iconDimension.height)
                        .clipShape(.circle)
                } else if let _ = phase.error {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: iconDimension.width, height: iconDimension.height)
                        .clipShape(.circle)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: iconDimension.width, height: iconDimension.height)
                        .clipShape(.circle)
                }
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(user.displayName ?? "")
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
