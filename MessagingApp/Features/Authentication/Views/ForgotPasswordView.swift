//
//  ForgotPasswordView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    @StateObject var viewModel = ForgotPasswordViewModel()
    
    var body: some View {
        ZStack {
            TapAreaView()
            
            VStack {
                Text("A password reset link will be sent to your email.")
                    .padding(.bottom)
                
                FormTextFieldView(formType: .email, formTitle: "Email", textFieldTitle: "Enter an email", errorMessage: $viewModel.emailErrorMessage, text: $viewModel.email)
                
                Button(action: sendResetLink) {
                    CustomAuthButtonLabelView(isLoading: $viewModel.isLoading, buttonTitle: "Send reset password link")
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    func sendResetLink() {
        hideKeyboard()
        viewModel.sendResetPasswordLink(alertMessageViewModel: alertMessageViewModel)
    }
}
