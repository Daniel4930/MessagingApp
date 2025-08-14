//
//  SendButtonView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/13/25.
//

import SwiftUI

struct SendButtonView: View {
    let action: () -> Void
    let frame: CGSize = CGSize(width: 25, height: 25)
    let rotationAngle: CGFloat = 45
    let backgroundColor: Color = .blue
    let color: Color = .white
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "paperplane.fill")
                .resizable()
                .rotationEffect(Angle(degrees: rotationAngle))
                .frame(width: frame.width, height: frame.height)
                .padding(10)
                .background(backgroundColor)
                .clipShape(.circle)
                .foregroundStyle(color)
        }
    }
}
