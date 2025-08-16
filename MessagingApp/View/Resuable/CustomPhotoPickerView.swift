//
//  CustomPhotoPickerView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/6/25.
//

import SwiftUI
import PhotosUI

struct CustomPhotoPickerView<Content: View>: View {
    let accessStatus: PhotoLibraryAccessStatus
    @Binding var height: CGFloat
    let minHeight: CGFloat
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    let photoPickerContent: () -> Content
    @State private var showPhotoPicker = false
    
    var body: some View {
        if accessStatus == .limitedAccess {
            photoPickerContent()
                .sheet(isPresented: $showPhotoPicker) {
                    PickerViewController(messageComposerViewModel: messageComposerViewModel, height: $height, minHeight: minHeight)
                }
                .onTapGesture {
                    showPhotoPicker.toggle()
                }
        } else {
            photoPickerContent()
        }
    }
}

enum LoadFileError: Error {
    case loadDataError
    case urlError
}

struct PickerViewController: UIViewControllerRepresentable {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var height: CGFloat
    let minHeight: CGFloat
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = MessageComposerViewModel.maxSelection
        config.preselectedAssetIdentifiers = messageComposerViewModel.selectionData.map { $0.identifier }
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiPickerViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, height: $height, minHeight: minHeight)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PickerViewController
        let height: Binding<CGFloat>
        let minHeight: CGFloat
        
        init(parent: PickerViewController, height: Binding<CGFloat>, minHeight: CGFloat) {
            self.parent = parent
            self.height = height
            self.minHeight = minHeight
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            height.wrappedValue = minHeight
            picker.dismiss(animated: true)
            
            //Remove data that doesn't exist in the results
            parent.messageComposerViewModel.selectionData = parent.messageComposerViewModel.selectionData.compactMap { data in
                if results.contains(where: { $0.assetIdentifier == data.identifier }) {
                    return data
                }
                return nil
            }

            for result in results {
                guard let identifier = result.assetIdentifier else {
                    print("No image identifier")
                    return
                }
                
                let provider = result.itemProvider
                if provider.registeredTypeIdentifiers.isEmpty { continue }
                
                if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    
//                    do {
                        provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                            guard error != nil else { return }
                            guard let url else { return }
                            let asset = AVURLAsset(url: url)
                            
                            Task {
                                let duration = try await asset.load(.duration)
                                print(try await asset.load(.commonMetadata))
                            }
                        }
                        
//                        let uploadedFile = UploadedFile(identifier: identifier, fileType: .video, photoInfo: nil, videoInfo: VideoFile(name: <#T##String#>, duration: <#T##Double#>, videoData: <#T##Data#>, thumbnail: <#T##Data#>), fileInfo: nil)
//                        DispatchQueue.main.async {
//                            self.parent.messageComposerViewModel.selectionData.append(uploadedFile)
//                        }
                        
//                    } catch let error as LoadFileError {
//                        switch error {
//                        case .loadDataError:
//                            print("Failed to load video data")
//                        case .urlError:
//                            print("Failed to get video url")
//                        }
//                    } catch {
//                        print("Unexpected error: \(error)")
//                    }
                }
                else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
//                    Task {
//                        do {
//                            let url = try await loadFileURL(provider: provider)
//                            let uploadedFile = UploadedFile(identifier: identifier, fileType: .photo, url: url)
//                            DispatchQueue.main.async {
//                                self.parent.messageComposerViewModel.selectionData.append(uploadedFile)
//                            }
//                        } catch let error as LoadFileError {
//                            switch error {
//                            case .loadDataError:
//                                print("Failed to load image data")
//                            case .urlError:
//                                print("Failed to get image url")
//                            }
//                        } catch {
//                            print("Unexpected error: \(error)")
//                        }
//                    }
                }
            }
        }
        
        private func loadFileURL(provider: NSItemProvider) async throws -> URL {
            guard let data = try await provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) as? Data else { throw LoadFileError.loadDataError }
            guard let url = URL(dataRepresentation: data, relativeTo: nil) else { throw LoadFileError.urlError }
            
            return url
        }
    }
}
