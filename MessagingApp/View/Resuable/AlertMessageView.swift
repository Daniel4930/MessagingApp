//
//  AlertMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/19/25.
//

import SwiftUI

struct AlertMessageView: View {
    @Binding var text: String
    let font: Font
    let isBold: Bool
    let textAlignment: TextAlignment
    @Binding var height: CGFloat
    @Binding var backgroundColor: Color
    let brightness: CGFloat
    static let maxHeight: CGFloat = 90
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height < 0 {
                    height = max(0, AlertMessageView.maxHeight + value.translation.height)
                }
            }
            .onEnded { value in
                if value.translation.height > 0 {
                    height = AlertMessageView.maxHeight
                } else {
                    height = 0
                    text = ""
                    backgroundColor = .clear
                }
            }
    }
    
    init(text: Binding<String>, font: Font = .headline, isBold: Bool = true, textAlignment: TextAlignment = .center, height: Binding<CGFloat>, backgroundColor: Binding<Color>, brightness: CGFloat = -0.5) {
        self._text = text
        self.font = font
        self.isBold = isBold
        self.textAlignment = textAlignment
        self._height = height
        self._backgroundColor = backgroundColor
        self.brightness = brightness
    }
    
    var body: some View {
        ZStack {
            backgroundColor.brightness(brightness)
                .overlay(alignment: .topTrailing) {
                    if height > 0 {
                        Button {
                            height = 0
                            text = ""
                            backgroundColor = .clear
                        } label: {
                            Text("x")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.white)
                                .padding(.top, 5)
                                .padding(.trailing, 10)
                        }
                    }
                }
            Text(text)
                .font(font)
                .multilineTextAlignment(textAlignment)
                .bold(isBold)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
                .padding(.top)
        }
        .frame(height: height)
        .gesture(dragGesture)
        .animation(.spring(duration: 0.5), value: height)
    }
}
