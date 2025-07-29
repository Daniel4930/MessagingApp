//
//  MessageDateView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/24/25.
//

import SwiftUI

struct MessageDateView: View {
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
            Text(MessageDateView.dateHeaderFormatter.string(from: date))
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
