//
//  ProfileFormViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 12/6/25.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class ProfileFormViewModel: ObservableObject {
    @Published var showAvatarEditor = false
    @Published var displayName = ""
    @Published var displayNameErrorMessage = ""
    @Published var aboutMe = ""
    @Published var bannerColor = Color.primaryBackground
    @Published var avatarImageData: Data?
    @Published var avatarPhotoPickerItem: [PhotosPickerItem] = []
    @Published var avatarImage: Image?
    @Published var removeAvatar = false
    @Published var saving = false
    @Published var saveEnable = false
    
    func initializeProfileInfo(userViewModel: UserViewModel) {
        if let user = userViewModel.user {
            displayName = user.displayName
            aboutMe = user.aboutMe
            bannerColor = Color(hex: user.bannerColor)
        }
    }
    
    func enableSaveAfterNewDisplayName(userViewModel: UserViewModel, newDisplayName: String) {
        if let user = userViewModel.user, newDisplayName != user.displayName {
            saveEnable = true
        } else {
            saveEnable = false
        }
    }
    
    func enableSaveAfterNewAboutMe(userViewModel: UserViewModel, newAboutMe: String) {
        if let user = userViewModel.user, newAboutMe != user.aboutMe {
            saveEnable = true
        } else {
            saveEnable = false
        }
    }
    
    func enableSaveAfterNewBannerColor(userViewModel: UserViewModel, newBannerColor: Color) {
        if let user = userViewModel.user, newBannerColor != Color(hex: user.bannerColor) {
            saveEnable = true
        } else {
            saveEnable = false
        }
    }
    
    func enableSaveAfterNewAvatarImage(newAvatarImage: Image?) {
        if newAvatarImage != nil {
            saveEnable = true
        } else {
            saveEnable = false
        }
    }
    
    func enableSaveAfterRemoveAvatar(removeAvatar: Bool) {
        if removeAvatar {
            saveEnable = true
        }
    }
    
    func newPhotosPickerItemValue(newPhotosPickerItem: [PhotosPickerItem]) {
        guard let firstItem = newPhotosPickerItem.first else {
            return
        }
        
        Task {
            if let data = try? await firstItem.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.avatarImage = Image(uiImage: uiImage)
                    self.avatarImageData = data
                    self.removeAvatar = false
                }
            } else {
                DispatchQueue.main.async {
                    self.avatarImage = nil
                    self.avatarImageData = nil
                }
            }
        }
    }
    
    func saveProfile(
        userViewModel: UserViewModel,
        dismissAction: DismissAction,
        alertViewModel: AlertMessageViewModel
    ) {
        displayNameErrorMessage = ""
        saving = true
        
        Task {
            do {
                if displayName.contains(" ") {
                    displayNameErrorMessage = "Display name can't contain spaces"
                }
                
                if displayNameErrorMessage.isEmpty {
                    try await userViewModel.saveUser(
                        displayName: displayName,
                        aboutMe: aboutMe,
                        bannerColor: bannerColor,
                        avatarImageData: avatarImageData,
                        removeAvatar: removeAvatar
                    )
                    dismissAction()
                }
            } catch {
                print("Error saving profile: \(error)")
                alertViewModel.presentAlert(message: "Failed to save profile picture", type: .error)
            }
            saving = false
        }
    }
    
    func toggleShowAvatarEditor() {
        showAvatarEditor.toggle()
    }
}
