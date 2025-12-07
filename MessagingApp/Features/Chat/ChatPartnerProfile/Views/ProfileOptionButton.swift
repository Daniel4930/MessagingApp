//
//  ProfileOptionButton.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/29/25.
//

import SwiftUI

struct ProfileOptionButton: View {
    let title: String
    let role: ButtonRole
    let action: () -> Void
    
    var body: some View {
        Button(role: role , action: action) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .contentShape(Rectangle())
    }
}
