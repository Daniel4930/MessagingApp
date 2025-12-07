//
//  SignupView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

@MainActor
struct SignupView: View {
    @Binding var currentView: CurrentView
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    
    @StateObject var signupViewModel = SignupViewModel()
    
    var body: some View {
        ScrollView {
            ZStack {
                TapAreaView()
                
                VStack {
                    FormTextFieldView(
                        formType: .email,
                        formTitle: "Email",
                        textFieldTitle: "Enter an email",
                        errorMessage: $signupViewModel.errorEmailMessage,
                        text: $signupViewModel.email
                    )
                    .padding(.bottom)
                    
                    FormTextFieldView(
                        formType: .password,
                        formTitle: "Password",
                        textFieldTitle: "Enter a password",
                        errorMessage: $signupViewModel.errorPasswordMessage,
                        text: $signupViewModel.password
                    )
                    
                    FormTextFieldView(
                        formType: .password,
                        formTitle: "Re-type password",
                        textFieldTitle: "Enter a password",
                        errorMessage: $signupViewModel.errorRetypePasswordMessage,
                        text: $signupViewModel.retypePassword
                    )
                    
                    passwordRequirements
                    
                    Button(action: buttonAction) {
                        CustomAuthButtonLabelView(isLoading: $signupViewModel.isLoading, buttonTitle: "Sign up")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    var passwordRequirements: some View {
        Group {
            Text("Password requirements:")
                .font(.headline)
            
            requirement("At least 8 characters")
            requirement("At least 1 uppercase letter")
            requirement("At least 1 lowercase letter")
            requirement("At least 1 number")
            requirement("At least 1 special character")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func requirement(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("•")
                .font(.headline)
            Text(text)
                .font(.body)
        }
    }
    
    func buttonAction() {
        Task {
            await signupViewModel.createNewUser(
                currentView: $currentView,
                userVM: userViewModel,
                alertMessageVM: alertMessageViewModel
            )
        }
    }
}
