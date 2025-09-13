//
//  EditProfileFormView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/3/25.
//

import SwiftUI
import PhotosUI

struct EditProfileFormView: View {
    @State private var showBannerColor = false
    @State private var showAvatarEditor = false
    @State private var topBarHeight: CGFloat = .zero
    @State private var profileIconHeight: CGFloat = .zero
    @State private var displayName: String = ""
    @State private var displayNameErrorMessage: String = ""
    @State private var aboutMe: String = ""
    @State private var bannerColor: Color = Color.primaryBackground
    @State private var avatarPhotoPickerItem: [PhotosPickerItem] = []
    @State private var avatarImage: Image?
    @State private var avatarImageData: Data?
    @State private var removeAvatar = false
    @State private var saveEnable = false
    @State private var saving = false
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar()
                .padding()
            
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            colorPickerButton()
                        }
                        userInfoSection()
                    }
                    .padding([.bottom, .horizontal])
                    .background(alignment: .top) {
                        Color(bannerColor)
                            .frame(height: profileIconHeight / 2 + topBarHeight)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        FormTextFieldView(formType: .text, formTitle: "Display Name", textFieldTitle: "Enter a diplay name", errorMessage: $displayNameErrorMessage, text: $displayName)
                            .padding(.bottom)
                        
                        Text("About Me")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)
                        
                        TextEditor(text: $aboutMe)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .padding(4)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.secondarySystemBackground))
                            )
                    }
                    .padding(.horizontal)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tint(.white)
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(.primaryBackground)
        .customSheetModifier(isPresented: $showAvatarEditor) {
            ChangeAvatarView(avatarPhotoPickerItem: $avatarPhotoPickerItem, avatarImage: $avatarImage, removeAvatar: $removeAvatar)
                .presentationDetents([.fraction(0.3)])
        }
        .onTapGesture {
            hideKeyboard()
        }
        .task {
            if let user = userViewModel.user {
                displayName = user.displayName
                aboutMe = user.aboutMe
                bannerColor = Color(hex: user.bannerColor)
            }
        }
        .onChange(of: displayName) { oldValue, newValue in
            if let user = userViewModel.user, newValue != user.displayName {
                saveEnable = true
            } else {
                saveEnable = false
            }
        }
        .onChange(of: aboutMe) { oldValue, newValue in
            if let user = userViewModel.user, newValue != user.aboutMe {
                saveEnable = true
            } else {
                saveEnable = false
            }
        }
        .onChange(of: bannerColor) { oldValue, newValue in
            if let user = userViewModel.user, newValue != Color(hex: user.bannerColor) {
                saveEnable = true
            } else {
                saveEnable = false
            }
        }
        .onChange(of: avatarPhotoPickerItem) { oldValue, newValue in
            guard let firstItem = newValue.first else {
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
        .onChange(of: avatarImage) { oldValue, newValue in
            if newValue != nil {
                saveEnable = true
            } else {
                saveEnable = false
            }
        }
        .onChange(of: removeAvatar) { oldValue, newValue in
            if newValue {
                saveEnable = true
            }
        }
    }
}

extension EditProfileFormView {
    func colorPickerButton() -> some View {
        Image(systemName: "pencil")
            .frame(width: 35, height: 35)
            .overlay {
                ColorPicker("", selection: $bannerColor)
                    .labelsHidden()
                    .opacity(0.05)
                    .contentShape(Circle())
            }
            .background {
                Circle().fill(.buttonBackground.opacity(0.8))
            }
            .padding(.top)
            .padding(.bottom, 40)
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            topBarHeight = proxy.size.height
                        }
                }
            }
    }
    
    func topNavigationBar() -> some View {
        HStack(alignment: .center) {
            Button {
                dismiss()
            } label: {
                Text("+")
                    .foregroundStyle(.white)
                    .font(.system(size: 40))
                    .rotationEffect(.degrees(45))
            }
            .modifier(TapGestureAnimation())
            
            Spacer()
            
            Text("Edit Profile")
                .font(.title2.bold())
            
            Spacer()
            
            Button {
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
                            dismiss()
                        }
                    } catch {
                        print("Error saving profile: \(error)")
                        alertViewModel.presentAlert(message: "Failed to save profile picture", type: .error)
                    }
                    saving = false
                }
            } label: {
                if saving {
                    ProgressView()
                } else {
                    Text("Save")
                }
            }
            .disabled(!saveEnable)
            .foregroundStyle(.blue)
            .opacity(saveEnable ? 1 : 0.5)
            .modifier(TapGestureAnimation())
        }
    }
    
    func userInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            let displayNameIsEmpty = displayName.isEmpty
            
            Button {
                showAvatarEditor.toggle()
            } label: {
                Group {
                    if let image = avatarImage {
                        image
                            .iconStyle(CGSize(width: 100, height: 100), borderColor: Color("PrimaryBackgroundColor"), borderWidth: 5)
                    } else if let user = userViewModel.user, !user.icon.isEmpty, !removeAvatar {
                        UserIconView(
                            urlString: user.icon,
                            iconDimension: CGSize(width: 100, height: 100),
                            borderColor: Color("PrimaryBackgroundColor"),
                            borderWidth: 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .iconStyle(CGSize(width: 100, height: 100), borderColor: Color("PrimaryBackgroundColor"), borderWidth: 5)
                            .foregroundStyle(.gray)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "pencil")
                        .padding(5)
                        .background {
                            Circle()
                                .fill(.buttonBackground)
                        }
                }
            }
            .padding(.bottom, 10)
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            profileIconHeight = proxy.size.height
                        }
                }
            }
            .modifier(TapGestureAnimation())
            
            if !displayNameIsEmpty {
                Text(displayName)
                    .font(.title2.bold())
            }
            
            Text(userViewModel.user!.userName)
                .font(displayNameIsEmpty ? .title2 : .body)
                .bold(displayNameIsEmpty)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}