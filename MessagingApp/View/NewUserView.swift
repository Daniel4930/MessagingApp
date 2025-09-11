//
//  NewUserView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/18/25.
//

import SwiftUI
import PhotosUI
import FirebaseMessaging

@MainActor
struct NewUserView: View {
    @Binding var currentView: CurrentView
    
    @State private var username: String = ""
    @State private var usernameErrorMessage: String = ""
    @State private var displayName: String = ""
    @State private var displayNameErrorMessage: String = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isLoading: Bool = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    
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
                        CustomAuthButtonLabelView(isLoading: $isLoading, buttonTitle: "Create")
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
                                alertViewModel.presentAlert(message: "Failed to upload image. Please try again", type: .error)
                            }
                        }
                    }
                }
            }
        }
    }
}
extension NewUserView {
    func buttonAction() {
        hideKeyboard()
        usernameErrorMessage = ""
        displayNameErrorMessage = ""
        isLoading = true
        
        if username.isEmpty {
            usernameErrorMessage = "Username is empty"
            isLoading = false
        }
        else if username.contains(where: { $0 == " " }) {
            usernameErrorMessage = "Username can't contain spaces"
            isLoading = false
        }
        if displayName.contains(where: { $0 == " "}) {
            displayNameErrorMessage = "Display name can't contain spaces"
            isLoading = false
        }
        
        if usernameErrorMessage.isEmpty && displayNameErrorMessage.isEmpty {
            Task {
                await updateUser()
            }
        }
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
                    let _ = FirebaseStorageService.shared.uploadDataToBucket(reference: ref, data: data) { result in
                        switch result {
                        case .success(let url):
                            continuation.resume(returning: url.absoluteString)
                        case .failure(let error):
                            switch error {
                            case .uploadFailed(let description):
                                print("Failed to upload image \(description)")
                                alertViewModel.presentAlert(message: "Failed to upload image to server", type: .error)
                            case .getDownloadUrlFailed(let description):
                                print("Failed to get uploaded image url \(description)")
                                alertViewModel.presentAlert(message: "Couldn't find image", type: .error)
                            case .noDownloadUrl:
                                print("No downloadable url for the uploaded image")
                                alertViewModel.presentAlert(message: "Server error. Please try again", type: .error)
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
    
    func updateUser() async {
        if let _ = await FirebaseCloudStoreService.shared.fetchUserByUsername(username: username) {
            usernameErrorMessage = "Username is taken"
            isLoading = false
            return
        }
        var dataToUpload: [String: Any] = [:]
        
        if selectedImage != nil {
            guard let imageUrl = await handleUploadImageToStorage() else {
                isLoading = false
                return
            }
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
        
        // Fetch and add FCM token to the user's data
        if let fcmToken = try? await Messaging.messaging().token() {
            dataToUpload["fcmToken"] = fcmToken
        }
        
        if let user = userViewModel.user, let id = user.id {
            do {
                try await FirebaseCloudStoreService.shared.updateData(collection: FirebaseCloudStoreCollection.users, documentId: id, newData: dataToUpload)
                
                await userViewModel.fetchCurrentUser(email: user.email)
                isLoading = false
                currentView = .content
            } catch {
                alertViewModel.presentAlert(message: "Failed to create user's information. Please try again", type: .error)
                isLoading = false
            }
        } else {
            alertViewModel.presentAlert(message: "Can't update user because userInfo is nil", type: .error)
            isLoading = false
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
