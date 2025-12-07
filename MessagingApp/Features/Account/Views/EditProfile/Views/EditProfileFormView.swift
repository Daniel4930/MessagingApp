//
//  EditProfileFormView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/3/25.
//

import SwiftUI
import PhotosUI

struct EditProfileFormView: View {
    @State private var topBarHeight: CGFloat = .zero
    @State private var profileIconHeight: CGFloat = .zero
    
    @StateObject private var viewModel = ProfileFormViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            colorPickerButton
                        }
                        userInfoSection
                    }
                    .padding([.bottom, .horizontal])
                    .background(alignment: .top) {
                        bannerColor
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        FormTextFieldView(
                            formType: .text,
                            formTitle: "Display Name",
                            textFieldTitle: "Enter a diplay name",
                            errorMessage: $viewModel.displayNameErrorMessage,
                            text: $viewModel.displayName
                        )
                        .padding(.bottom)
                        
                        aboutMeView
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
        .customSheetModifier(isPresented: $viewModel.showAvatarEditor) {
            ChangeAvatarView(
                avatarPhotoPickerItem: $viewModel.avatarPhotoPickerItem,
                avatarImage: $viewModel.avatarImage,
                removeAvatar: $viewModel.removeAvatar
            )
            .presentationDetents([.fraction(0.3)])
        }
        .onTapGesture {
            hideKeyboard()
        }
        .task {
            viewModel.initializeProfileInfo(userViewModel: userViewModel)
        }
        .onChange(of: viewModel.displayName) { oldValue, newValue in
            viewModel.enableSaveAfterNewDisplayName(userViewModel: userViewModel, newDisplayName: newValue)
        }
        .onChange(of: viewModel.aboutMe) { oldValue, newValue in
            viewModel.enableSaveAfterNewAboutMe(userViewModel: userViewModel, newAboutMe: newValue)
        }
        .onChange(of: viewModel.bannerColor) { oldValue, newValue in
            viewModel.enableSaveAfterNewBannerColor(userViewModel: userViewModel, newBannerColor: newValue)
        }
        .onChange(of: viewModel.avatarPhotoPickerItem) { oldValue, newValue in
            viewModel.newPhotosPickerItemValue(newPhotosPickerItem: newValue)
        }
        .onChange(of: viewModel.avatarImage) { oldValue, newValue in
            viewModel.enableSaveAfterNewAvatarImage(newAvatarImage: newValue)
        }
        .onChange(of: viewModel.removeAvatar) { oldValue, newValue in
            viewModel.enableSaveAfterRemoveAvatar(removeAvatar: newValue)
        }
    }
}

// MARK: - View components
extension EditProfileFormView {
    var bannerColor: some View {
        Color(viewModel.bannerColor)
            .frame(height: profileIconHeight / 2 + topBarHeight)
    }
    
    var exitFormButtonLabelView: some View {
        Button(action: { dismiss() }) {
            Text("+")
                .foregroundStyle(.white)
                .font(.system(size: 40))
                .rotationEffect(.degrees(45))
        }
        .modifier(TapGestureAnimation())
    }
    
    @ViewBuilder var saveButtonView: some View {
        if viewModel.saving {
            ProgressView()
        } else {
            Text("Save")
        }
    }
    
    @ViewBuilder var topNavigationBar: some View {
        HStack(alignment: .center) {
            exitFormButtonLabelView
            
            Spacer()
            
            Text("Edit Profile")
                .font(.title2.bold())
            
            Spacer()
            
            Button(action: { viewModel.saveProfile(
                userViewModel: userViewModel,
                dismissAction: dismiss,
                alertViewModel: alertViewModel
            ) }) {
                saveButtonView
            }
            .disabled(!viewModel.saveEnable)
            .foregroundStyle(.blue)
            .opacity(viewModel.saveEnable ? 1 : 0.5)
            .modifier(TapGestureAnimation())
        }
        .padding()
    }
    
    var colorPickerButton: some View {
        Image(systemName: "pencil")
            .frame(width: 35, height: 35)
            .overlay {
                ColorPicker("", selection: $viewModel.bannerColor)
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
                topBarHeightReaderView
            }
    }
    
    var topBarHeightReaderView: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    topBarHeight = proxy.size.height
                }
        }
    }
    
    var profileIconHeightReaderView: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    profileIconHeight = proxy.size.height
                }
        }
    }
    
    var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            let displayNameIsEmpty = viewModel.displayName.isEmpty
            
            Button(action: viewModel.toggleShowAvatarEditor) {
                userAvatarView
            }
            .padding(.bottom, 10)
            .overlay {
                profileIconHeightReaderView
            }
            .modifier(TapGestureAnimation())
            
            userNameView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder var userAvatarView: some View {
        Group {
            if let image = viewModel.avatarImage {
                image
                    .iconStyle(CGSize(width: 100, height: 100), borderColor: Color("PrimaryBackgroundColor"), borderWidth: 5)
            } else if let user = userViewModel.user, !user.icon.isEmpty, !viewModel.removeAvatar {
                UserIconView(
                    urlString: user.icon,
                    iconDimension: CGSize(width: 100, height: 100),
                    borderColor: Color("PrimaryBackgroundColor"),
                    borderWidth: 5
                )
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
    
    @ViewBuilder var userNameView: some View {
        let displayNameIsEmpty = viewModel.displayName.isEmpty
        
        if !displayNameIsEmpty {
            Text(viewModel.displayName)
                .font(.title2.bold())
        }
        
        Text(userViewModel.user!.userName)
            .font(displayNameIsEmpty ? .title2 : .body)
            .bold(displayNameIsEmpty)
    }
    
    @ViewBuilder var aboutMeView: some View {
        Text("About Me")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 4)
        
        TextEditor(text: $viewModel.aboutMe)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding(4)
            .scrollContentBackground(.hidden)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
            )
    }
}
