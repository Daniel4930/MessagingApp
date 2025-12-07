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
    
    var body: some View {
        Button(action: buttonAction) {
            Image(systemName: "plus")
                .resizable()
                .modifier(SelectorButtonViewModifier(showSelector: $showFileAndImageSelector))
        }
        .rotationEffect(.degrees(0))
    }
}

// MARK: View actions
extension SelectorButtonLayoutView {
    func buttonAction() {
        if showFileAndImageSelector {
            keyboardProvider.keyboardWillAppear = true
            focusedField = .textField
        }
        showFileAndImageSelector.toggle()
    }
}
