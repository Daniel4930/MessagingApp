//
//  LineIndicator.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/27/25.
//

import SwiftUI

struct LineIndicator: View {
    let cornerRadius: CGFloat
    let color: Color
    let width: CGFloat
    let height: CGFloat
    
    init(cornerRadius: CGFloat = 20, color: Color = Color.buttonBackground, width: CGFloat = 40, height: CGFloat = 5) {
        self.cornerRadius = cornerRadius
        self.color = color
        self.width = width
        self.height = height
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color)
            .frame(width: width, height: height)
    }
}
