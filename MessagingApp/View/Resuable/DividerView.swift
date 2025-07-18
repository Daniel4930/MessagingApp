//
//  DividerView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//


import SwiftUI

struct DividerView: View {
    let color: Color
    let thickness: CGFloat
    let padding: (edge: Edge.Set, value: CGFloat)?
    
    init(color: Color = .gray, thickness: CGFloat = 0.4, padding: (Edge.Set, CGFloat)? = nil) {
        self.color = color
        self.thickness = thickness
        self.padding = padding
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: thickness)
            .ignoresSafeArea(edges: .horizontal)
            .applyPadding(padding)
    }
}
