//
//  SelectorView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//

import SwiftUI

struct SelectorView: View {
    @State private var keyboardHeight: CGFloat = 216
    
    var body: some View {
        VStack {
            
        }
        .modifier(KeyboardHeightProvider(height: $keyboardHeight))
        .frame(height: keyboardHeight)
        .background(.gray)
    }
}
