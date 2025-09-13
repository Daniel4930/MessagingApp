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
    case text
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
            
            HStack {
                Group {
                    switch formType {
                    case .email:
                        TextField(textFieldTitle, text: $text)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    case .password:
                        SecureField(textFieldTitle, text: $text)
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    case .text:
                        TextField(textFieldTitle, text: $text)
                    }
                }
                
                if formType != .password {
                    Text("+")
                        .font(.title2.bold())
                        .rotationEffect(.degrees(45))
                        .foregroundStyle(.secondaryBackground)
                        .frame(width: 25, height: 25)
                        .background {
                            Circle()
                                .fill(.button)
                                .brightness(-0.5)
                        }
                        .onTapGesture {
                            text = ""
                        }
                        .modifier(TapGestureAnimation())
                }

            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
            )
            
            Text(errorMessage.isEmpty ? " " : "*\(errorMessage)")
                .font(.subheadline)
                .foregroundColor(.red)
        }
    }
}
