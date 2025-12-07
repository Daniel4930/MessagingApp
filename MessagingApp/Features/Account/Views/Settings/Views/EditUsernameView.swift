
import SwiftUI

struct EditUsernameView: View {
    @StateObject private var viewModel = EditUsernameViewModel()
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            FormTextFieldView(
                formType: .text,
                formTitle: "Username",
                textFieldTitle: "Enter a new username",
                errorMessage: $viewModel.usernameErrorMessage,
                text: $viewModel.newUsername
            )
            
            usernameRequirementView
            
            Button {
                Task {
                    await viewModel.updateUsername(userViewModel: userViewModel, alertMessageViewModel: alertMessageViewModel)
                }
            } label: {
                CustomAuthButtonLabelView(isLoading: $viewModel.isLoading, buttonTitle: "Save")
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Edit Username")
        .onAppear { viewModel.initializeUsername(userViewModel: userViewModel) }
    }
}

// MARK: - View components
extension EditUsernameView {
    var usernameRequirementView: some View {
        Text("Username can't contain spaces.")
            .font(.footnote)
            .foregroundColor(.gray)
    }
}
