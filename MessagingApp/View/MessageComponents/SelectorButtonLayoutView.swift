//
//  SelectorButtonLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/17/25.
//
import SwiftUI

struct SelectorButtonLayoutView: View {
    @Binding var showFileAndImageSelector: Bool
    @FocusState.Binding var focusedField: Field?
    
    @EnvironmentObject var keyboardProvider: KeyboardProvider
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (23, 23)
    let animationDuration: Double = 0.3
    let rotationAngle: Double = 45.0
    let paddingSpace: CGFloat = 10
    
    var body: some View {
        Button {
            if showFileAndImageSelector {
                keyboardProvider.keyboardWillAppear = true
                focusedField = .textField
            }
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
                .animation(.spring(duration: animationDuration, bounce: 0), value: showFileAndImageSelector)
        }
        .rotationEffect(.degrees(0))
    }
}
