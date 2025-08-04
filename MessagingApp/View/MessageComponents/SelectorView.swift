//
//  SelectorView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//

import SwiftUI
import PhotosUI
import Photos

struct SelectorView: View {
    let minHeight: CGFloat
    @Binding var selectedPhotosAndFiles: [(image: UIImage?, file: Data?)]
    let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.898
    let threshold: CGFloat = UIScreen.main.bounds.height * 0.6
    let gridColums = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var height: CGFloat = .zero
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var openCamera = false
    @State private var photoLibraryAccessAlertTitle = ""
    @State private var showPhotoLibraryAccessAlert = false
    @State private var photoLibraryAccessPermissonGranted = false
    
    var gesture: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                if dragValue.translation.height < 0 && height <= maxHeight {
                    if height + abs(dragValue.translation.height) <= maxHeight {
                        height += abs(dragValue.translation.height)
                    }
                }
                if dragValue.translation.height > 0 && height > minHeight {
                    if height + dragValue.translation.height > minHeight {
                        height -= dragValue.translation.height
                    }
                }
            }
            .onEnded { dragValue in
                if height > threshold {
                    height = maxHeight
                } else {
                    height = minHeight
                }
            }
    }
    
    var body: some View {
        VStack {
            LineIndicator()
            
            if height >= maxHeight {
                SelectorNavTopBar(height: $height, minHeight: minHeight, photoPickerItems: $photoPickerItems)
                    .highPriorityGesture(gesture)
            } else {
                PollsAndFilesButtonsView()
                    .highPriorityGesture(gesture)
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text("You've given us access to a select number of photos and videos.")
                        
                        Spacer()
                        
                        if photoLibraryAccessPermissonGranted {
                            PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 10) {
                                Text("Manage")
                                    .padding(14)
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.secondaryBackground)
                                    }
                            }
                        } else {
                            Button {
                                handlePhotoLibraryAccessRequest()
                            } label: {
                                Text("Manage")
                                    .padding(14)
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.secondaryBackground)
                                    }
                            }
                        }
                    }
                    
                    LazyVGrid(columns: gridColums) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.buttonBackground)
                            .frame(width: 120, height: 120)
                            .overlay {
                                Image(systemName: "camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            }
                            .onTapGesture {
                                openCamera.toggle()
                            }
                            .fullScreenCover(isPresented: $openCamera) {
                                ImagePickerView()
                            }
                        
                        ForEach(photoPickerItems, id: \.self) { item in
                            PhotoThumbnailView(item: item, selectedPhotosAndFiles: $selectedPhotosAndFiles)
                        }
                    }
                    .padding(.vertical)
                    
                    Text("Not what you're looking for? Browse your photo library for that perfect picture.")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 10) {
                        Text("Browse Photos")
                            .bold()
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.blue)
                                    .frame(width: 150)
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .font(.subheadline)
            .padding(.horizontal)
            .scrollDisabled(height == maxHeight ? false : true)
        }
        .foregroundStyle(Color.button)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color.primaryBackground)
        .gesture(gesture)
        .onAppear {
            height = minHeight
            handlePhotoLibraryAccessRequest()
        }
        .onChange(of: minHeight) { _, newValue in
            height = newValue
        }
        .alert(photoLibraryAccessAlertTitle, isPresented: $showPhotoLibraryAccessAlert) {
            Button("Settings") {
                if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingUrl)
                }
            }
            
            Button("Done", role: .cancel) { }
        } message: {
            Text("Go to setting -> MessagingApp -> Photos -> Choose an access to use photos and videos in the app")
        }
    }
}

extension SelectorView {
    func handlePhotoLibraryAccessRequest() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                photoLibraryAccessPermissonGranted = true
            case .limited:
                photoLibraryAccessPermissonGranted = true
            case .denied:
                photoLibraryAccessPermissonGranted = false
                photoLibraryAccessAlertTitle = "Access to photo library was denied"
                showPhotoLibraryAccessAlert.toggle()
            case .restricted:
                photoLibraryAccessPermissonGranted = false
                photoLibraryAccessAlertTitle = "Access to photo library was restricted"
                showPhotoLibraryAccessAlert.toggle()
            case .notDetermined:
                photoLibraryAccessPermissonGranted = false
                break
            @unknown default:
                fatalError("Unknown authorization status.")
            }
        }
    }
}

struct PollsAndFilesButtonsView: View {
    @State private var importing = false
    
    var body: some View {
        HStack {
            NavigationLink {
                Text("poll")
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal")
                    Text("Polls")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.buttonBackground)
                )
            }
            
            Button {
                importing = true
            } label: {
                HStack {
                    Image(systemName: "paperclip")
                    Text("Files")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.buttonBackground)
                )
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.content]) { result in
                switch result {
                case .success(let file):
                    print(file.absoluteString)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        .font(.subheadline)
        .bold()
        .padding()
    }
}
