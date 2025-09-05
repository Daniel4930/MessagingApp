
import SwiftUI

struct EditUsernameView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    
    @State private var newUsername: String = ""
    @State private var usernameErrorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            FormTextFieldView(formType: .text, formTitle: "Username", textFieldTitle: "Enter a new username", errorMessage: $usernameErrorMessage, text: $newUsername)
            
            Text("Username can't contain spaces.")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Button {
                updateUsername()
            } label: {
                CustomAuthButtonLabelView(isLoading: $isLoading, buttonTitle: "Save")
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Edit Username")
        .onAppear {
            if let username = userViewModel.user?.userName {
                newUsername = username
            }
        }
    }
    
    func updateUsername() {
        usernameErrorMessage = ""
        isLoading = true
        
        if newUsername.isEmpty {
            usernameErrorMessage = "Username is empty"
            isLoading = false
            return
        }
        
        if newUsername.contains(" ") {
            usernameErrorMessage = "Username can't contain spaces"
            isLoading = false
            return
        }
        
        Task {
            do {
                try await userViewModel.updateUsername(newUsername: newUsername)
                alertMessageViewModel.presentAlert(message: "Username updated successfully", type: .success)
            } catch {
                alertMessageViewModel.presentAlert(message: error.localizedDescription, type: .error)
            }
            isLoading = false
        }
    }
}
