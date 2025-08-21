//
//  NewUserView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/18/25.
//

import SwiftUI
import PhotosUI

@MainActor
struct NewUserView: View {
    @Binding var currentView: CurrentView
    
    @State private var username: String = ""
    @State private var usernameErrorMessage: String = ""
    @State private var displayName: String = ""
    @State private var displayNameErrorMessage: String = ""
    @State private var generalErrorMessage: String = ""
    @State private var generalErrorMessageColor: Color = .clear
    @State private var generalErrorMessageHeight: CGFloat = .zero
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isLoading: Bool = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ScrollView {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
                VStack(spacing: 16) {
                    HStack(alignment: .center) {
                        profileImage()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(displayName.isEmpty ? username : displayName)
                                .font(.title3)
                                .bold()
                            Text(username)
                                .font(.subheadline)
                        }
                    }
                    .padding(.top, AlertMessageView.maxHeight)
                    
                    Text("Create your profile")
                        .font(.title2)
                        .bold()
                    
                    
                    FormTextFieldView(formType: .text, formTitle: "Username", textFieldTitle: "Enter a username", errorMessage: $usernameErrorMessage, text: $username)
                    
                    FormTextFieldView(formType: .text, formTitle: "Display name (display this instead of username)", textFieldTitle: "(Optional) Enter a display name", errorMessage: $displayNameErrorMessage, text: $displayName)
                    
                    PhotosPicker(selection: $photoItem, matching: .any(of: [.images, .screenshots]), photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo")
                            Text("(Optional) Pick a profile picture")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        buttonAction()
                    } label: {
                        CustomButtonLabelView(isLoading: $isLoading, buttonTitle: "Create")
                    }
                }
                .padding(.horizontal)
                .onChange(of: photoItem) { oldItem, newItem in
                    Task {
                        if let newItem {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            } else {
                                setupErrorMessage(message: "Failed to upload image. Please try again")
                            }
                        }
                    }
                }
                .overlay(alignment: .top) {
                    AlertMessageView(text: $generalErrorMessage, height: $generalErrorMessageHeight, backgroundColor: $generalErrorMessageColor)
                }
            }
        }
    }
}
extension NewUserView {
    func buttonAction() {
        usernameErrorMessage = ""
        displayNameErrorMessage = ""
        generalErrorMessage = ""
        isLoading = true
        
        if username.isEmpty {
            usernameErrorMessage = "Username is empty"
            isLoading = false
        }
        else if username.contains(where: { $0 == " " }) {
            usernameErrorMessage = "Username can't contain a space"
            isLoading = false
        }
        if displayName.contains(where: { $0 == " "}) {
            displayNameErrorMessage = "Display name can't contain a space"
            isLoading = false
        }
        
        if usernameErrorMessage.isEmpty && displayNameErrorMessage.isEmpty && generalErrorMessage.isEmpty {
            Task {
                await checkUsernameAlreadyExists()
            }
        }
    }
    
    func setupErrorMessage(message: String, color: Color = .red) {
        generalErrorMessage = message
        generalErrorMessageColor = color
        generalErrorMessageHeight = AlertMessageView.maxHeight
    }
    
    func handleUploadImageToStorage() async -> String? {
        var fileName = "\(username)."
        var imageData: Data?
        
        if let selectedImage = selectedImage {
            if let jpegData = selectedImage.jpegData(compressionQuality: 1) {
                imageData = jpegData
                fileName.append("jpeg")
            } else if let pngData = selectedImage.pngData() {
                imageData = pngData
                fileName.append("png")
            } else if let heicData = selectedImage.heicData() {
                imageData = heicData
                fileName.append("heic")
            }
            
            if let data = imageData {
                let ref = FirebaseStorageService.shared.createChildReference(folder: .icons, fileName: fileName)
                
                return await withCheckedContinuation { continuation in
                    FirebaseStorageService.shared.uploadDataToBucket(reference: ref, data: data) { result in
                        switch result {
                        case .success(let url):
                            continuation.resume(returning: url.absoluteString)
                        case .failure(let error):
                            switch error {
                            case .uploadFailed(let description):
                                print("Failed to upload image \(description)")
                                generalErrorMessage = "Failed to upload image to server"
                            case .getDownloadUrlFailed(let description):
                                print("Failed to get uploaded image url \(description)")
                                generalErrorMessage = "Couldn't find image"
                            case .noDownloadUrl:
                                print("No downloadable url for the uploaded image")
                                generalErrorMessage = "Server error. Please try again"
                            }
                            self.selectedImage = nil
                            continuation.resume(returning: nil)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func checkUsernameAlreadyExists() async {
        guard let exists = await FirebaseCloudStoreService.shared.checkIfUsernameExists(username: username) else {
            setupErrorMessage(message: "Internal Error")
            isLoading = false
            return
        }
        
        if exists {
            usernameErrorMessage = "Username is taken"
            isLoading = false
        } else {
            var dataToUpload: [String: Any] = [:]
            
            if let imageUrl = await handleUploadImageToStorage() {
                dataToUpload = [
                    "userName": username,
                    "displayName": displayName,
                    "icon": imageUrl
                ]
            } else {
                dataToUpload = [
                    "userName": username,
                    "displayName": displayName
                ]
            }
            
            if let user = userViewModel.user {
                let result = await FirebaseCloudStoreService.shared.updateUser(documentId: user.id, newData: dataToUpload)
                switch result {
                case .success(_):
                    await userViewModel.fetchCurrentUser(email: user.email)
                    isLoading = false
                    currentView = .content
                case .failure(let failure):
                    switch failure {
                    case .updateFailed(let errorDescription):
                        print("Failed to update user: \(errorDescription)")
                        setupErrorMessage(message: "Failed to create user's information. Please try again")
                        isLoading = false
                    }
                }
            } else {
                setupErrorMessage(message: "Can't update user because userInfo is nil")
                isLoading = false
            }
        }
    }
    
    @ViewBuilder
    func profileImage() -> some View {
        if let selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
        } else {
            Image(systemName: "person.fill")
                .resizable()
        }
    }
}
