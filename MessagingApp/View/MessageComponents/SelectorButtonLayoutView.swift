//
//  SelectorButtonLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/17/25.
//
import SwiftUI

struct SelectorButtonLayoutView: View {
    @Binding var showFileAndImageSelector: Bool
    @FocusState.Binding var textEditorFocusedField: Bool
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (25, 25)
    let animationDelay: Double = 0.05
    let rotationAngle: Double = 45.0
    let paddingSpace: CGFloat = 10
    
    var body: some View {
        Button {
            showFileAndImageSelector.toggle()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .rotationEffect(.degrees(showFileAndImageSelector ? rotationAngle : 0))
                .frame(width: iconDimension.width, height: iconDimension.height)
                .padding(paddingSpace)
                .background(Color("SecondaryBackgroundColor"))
                .clipShape(.circle)
                .foregroundStyle(showFileAndImageSelector ? .blue : .white)
                .animation(.easeInOut.delay(animationDelay), value: showFileAndImageSelector)
        }
        .rotationEffect(.degrees(0))
    }
}
