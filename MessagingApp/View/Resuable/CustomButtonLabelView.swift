//
//  CustomButtonLabelView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/19/25.
//

import SwiftUI

struct CustomButtonLabelView: View {
    let buttonTitle: String
    let forgroundColor: Color
    let verticalPadding: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color
    
    init(buttonTitle: String, forgroundColor: Color = .white, verticalPadding: CGFloat = 10, cornerRadius: CGFloat = 10, backgroundColor: Color = .blue) {
        self.buttonTitle = buttonTitle
        self.forgroundColor = forgroundColor
        self.verticalPadding = verticalPadding
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Text(buttonTitle)
            .foregroundStyle(forgroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, verticalPadding)
            .background (
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
    }
}
