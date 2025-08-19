//
//  FormTextFieldView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI

enum FormType {
    case email
    case password
}

struct FormTextFieldView: View {
    let formType: FormType
    let formTitle: String
    let textFieldTitle: String
    @Binding var errorMessage: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formTitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Group {
                switch formType {
                case .email:
                    TextField(text: $text) {
                        Text(textFieldTitle)
                    }
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    
                case .password:
                    SecureField(text: $text) {
                        Text(textFieldTitle)
                    }
                    .textContentType(.password)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground)) // example background
            )
            
            Text(errorMessage.isEmpty ? " " : "*\(errorMessage)")
                .font(.footnote)
                .foregroundColor(.red)
        }
    }
}
