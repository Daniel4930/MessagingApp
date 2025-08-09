//
//  SelectorView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/15/25.
//

import SwiftUI
import PhotosUI
import Photos

enum PhotoLibraryAccessStatus {
    case fullAccess
    case limitedAccess
    case restricted
    case denied
    case undetermined
}

struct SelectorView: View {
    let minHeight: CGFloat
    @ObservedObject var uploadDataViewModel: UploadDataViewModel
    let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.898
    let threshold: CGFloat = UIScreen.main.bounds.height * 0.6
    
    @State private var height: CGFloat = .zero
    @State private var openCamera = false
    @State private var photoLibraryAccessPermissonGranted = false
    @State private var accessStatus: PhotoLibraryAccessStatus?
    @State private var assets: [PHAsset] = []
    
    @State private var enableHighPriorityGesture = false
    
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
            
            if height >= threshold {
                SelectorNavTopBar(
                    height: $height,
                    minHeight: minHeight,
                    accessStatus: accessStatus ?? .undetermined,
                    uploadDataViewModel: uploadDataViewModel
                )
                    .highPriorityGesture(gesture)
            } else {
                PollsAndFilesButtonsView()
                    .highPriorityGesture(gesture)
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    switch accessStatus {
                    case .fullAccess:
                        PhotosAndVideosGridView(assets: $assets, refreshAssets: getPhotosAndVideosAssets, uploadDataViewModel: uploadDataViewModel)
                            .task {
                                getPhotosAndVideosAssets()
                            }
                        
                    case .limitedAccess:
                        LimitedLibraryAccessMessageView(getAssets: getPhotosAndVideosAssets)
                        
                        PhotosAndVideosGridView(assets: $assets, refreshAssets: getPhotosAndVideosAssets, uploadDataViewModel: uploadDataViewModel)
                        
                        BrowsePhotosAndVideosView(
                            accessStatus: accessStatus ?? .undetermined,
                            uploadDataViewModel: uploadDataViewModel,
                            height: $height,
                            minHeight: minHeight
                        )
                        
                    case .restricted, .denied, .undetermined, nil:
                        NoPhotoLibraryMessageView()
                    }
                }
            }
            .font(.subheadline)
            .padding(.horizontal)
            .highPriorityGesture(gesture, isEnabled: height == minHeight)
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
    }
}

extension SelectorView {
    func handlePhotoLibraryAccessRequest() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                photoLibraryAccessPermissonGranted = true
                accessStatus = .fullAccess
            case .limited:
                photoLibraryAccessPermissonGranted = true
                accessStatus = .limitedAccess
            case .denied:
                photoLibraryAccessPermissonGranted = false
                accessStatus = .denied
            case .restricted:
                photoLibraryAccessPermissonGranted = false
                accessStatus = .restricted
            case .notDetermined:
                break
            @unknown default:
                fatalError("Unknown authorization status.")
            }
        }
    }
    
    func getPhotosAndVideosAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        DispatchQueue.main.async {
            assets = []
            if results.count > 0 {
                for i in 0..<results.count {
                    assets.append(results[i])
                }
            } else {
                print("No photos or videos")
            }
        }
    }
}
