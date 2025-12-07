//
//  TapAreaView.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/19/25.
//

import SwiftUI

struct TapAreaView: View {
    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
    }
}
