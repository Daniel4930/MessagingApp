//
//  LoginView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI
import FirebaseMessaging

struct LoginView: View {
    @Binding var currentView: CurrentView
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    
    @StateObject private var viewModel = LoginViewModel()
    
    init(currentView: Binding<CurrentView>) {
        _currentView = currentView
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                TapAreaView()
                
                VStack {
                    FormTextFieldView(
                        formType: .email,
                        formTitle: "Email",
                        textFieldTitle: "Enter an email",
                        errorMessage: $viewModel.errorEmailMessage,
                        text: $viewModel.email
                    )
                        .padding(.bottom)
                    
                    FormTextFieldView(
                        formType: .password,
                        formTitle: "Password",
                        textFieldTitle: "Enter a password",
                        errorMessage: $viewModel.errorPasswordMessage,
                        text: $viewModel.password
                    )
                    
                    accountActionView
                    
                    Button(action: signIn) {
                        CustomAuthButtonLabelView(isLoading: $viewModel.isLoading, buttonTitle: "Login")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
    
    var accountActionView: some View {
        HStack {
            NavigationLink(destination: ForgotPasswordView()) {
                Text("Forgot password")
            }
            
            Spacer()
            
            NavigationLink(destination: SignupView(currentView: $currentView)) {
                Text("Create a new account")
            }
        }
        .frame(maxWidth: .infinity)
        .font(.subheadline)
        .padding(.top)
    }
    
    func signIn() {
        hideKeyboard()
        
        Task {
            await viewModel.signIn(
                currentView: $currentView,
                userViewModel: userViewModel,
                friendViewModel: friendViewModel,
                alertMessageViewModel: alertMessageViewModel
            )
        }
    }
}
