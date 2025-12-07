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
    
    var body: some View {
        HStack {
            DividerView(color: .gray, thickness: dividerLineThickness)
            
            Text(MessageDateView.dateHeaderFormatter.string(from: date))
                .foregroundStyle(.gray)
                .fontWeight(.bold)
                .font(.footnote)
                .padding(.horizontal, 8)
                .lineLimit(1)
                .layoutPriority(1)
            
            DividerView(color: .gray, thickness: dividerLineThickness)
        }
    }
}

// MARK: Data components
extension MessageDateView {
    static let dateHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
}
