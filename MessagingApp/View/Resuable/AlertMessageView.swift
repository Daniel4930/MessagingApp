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
    static let maxHeight: CGFloat = 150
    static let dismissAfter: TimeInterval = 3
    
    @State private var dismissTask: Task<Void, Never>?
    
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
                    text = ""
                    height = 0
                    backgroundColor = .clear
                }
            }
    }
    
    init(text: Binding<String>, font: Font = .title2, isBold: Bool = true, textAlignment: TextAlignment = .center, height: Binding<CGFloat>, backgroundColor: Binding<Color>, brightness: CGFloat = -0.5) {
        self._text = text
        self.font = font
        self.isBold = isBold
        self.textAlignment = textAlignment
        self._height = height
        self._backgroundColor = backgroundColor
        self.brightness = brightness
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(backgroundColor)
            .brightness(brightness)
            .frame(height: height)
            .gesture(dragGesture)
            .animation(.spring(duration: 0.5), value: height)
            .animation(.spring(duration: 0.5), value: text)
            .animation(.spring(duration: 0.5), value: backgroundColor)
            .overlay {
                Text(text)
                    .font(font)
                    .multilineTextAlignment(textAlignment)
                    .bold(isBold)
                    .padding(.horizontal)
                    .padding(.top)
            }
            .onChange(of: text) { oldText, newText in
                dismissTask?.cancel()
                
                if !newText.isEmpty {
                    dismissTask = Task {
                        do {
                            try await Task.sleep(for: .seconds(AlertMessageView.dismissAfter))
                            text = ""
                            height = 0
                            backgroundColor = .clear
                        } catch {
                            // Task was cancelled.
                        }
                    }
                }
            }
            .ignoresSafeArea()
    }
}
