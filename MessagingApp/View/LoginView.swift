//
//  LoginView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import SwiftUI

struct LoginView: View {
    @Binding var currentView: Tabs
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Enter an email", text: $email)
                } header: {
                    Text("Email")
                }
                
                Section {
                    TextField("Enter a password", text: $password)
                } header: {
                    Text("Password")
                }
            }
            .padding(.bottom)
            
            Button("Login") {
                if !email.isEmpty && !password.isEmpty {
                    Task {
                        // Check if email is already exist
                        // Authenticate user
                        let result = await FirebaseCloudStoreService.shared.loginUser(email: email, password: password)
                        
                        DispatchQueue.main.async {
                            self.currentView = result ? .home : .login
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}
