//
//  SelectorView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//

import SwiftUI

struct SelectorView: View {
    let height: CGFloat
    
    var body: some View {
        VStack {
            Text("Hello")
        }
        .frame(height: height)
        .background(.gray)
        .onTapGesture {
            hideKeyboard()
        }
    }
}
