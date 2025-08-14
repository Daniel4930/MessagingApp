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

enum LoadVideoError: Error {
    case thumbnailError
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
                    Task {
                        do {
                            let fileURL = try await loadVideoFileURL(provider: provider)
                            
                            let avAsset = AVURLAsset(url: fileURL)
                            
                            let duration = try await CMTimeGetSeconds(avAsset.load(.duration))
                            
                            let imageGenerator = AVAssetImageGenerator(asset: avAsset)
                            imageGenerator.appliesPreferredTrackTransform = true
                            
                            let thumbnail = try await generateThumbnail(from: avAsset)
                            
                            guard let videoData = try? Data(contentsOf: fileURL) else {
                                print("Failed to get video data")
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.parent.messageComposerViewModel.selectionData.append(UploadData(identifier: identifier, data: (nil, UploadData.VideoData(thumbnail: thumbnail, content: videoData, duration: duration), nil)))
                            }
                            
                        } catch {
                            print("Video loading error: \(error)")
                        }
                    }
                }
                else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    if provider.canLoadObject(ofClass: UIImage.self) {
                        provider.loadObject(ofClass: UIImage.self) { (image, error) in
                            if let error = error {
                                print("Error loading image: \(error.localizedDescription)")
                                return
                            }
                            if let image = image as? UIImage {
                                DispatchQueue.main.async {
                                    self.parent.messageComposerViewModel.selectionData.append(UploadData(identifier: identifier, data: (photo: UploadData.PhotoData(image: image), nil, nil)))
                                }
                            }
                        }
                    }
                    else {
                        print("Cannot load object to UIImage")
                    }
                }
            }
        }

        private func generateThumbnail(from asset: AVAsset) async throws -> UIImage {
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            return try await withCheckedThrowingContinuation { continuation in
                imageGenerator.generateCGImageAsynchronously(for: .zero) { cgImage, _, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let cgImage = cgImage else {
                        continuation.resume(throwing: LoadVideoError.thumbnailError)
                        return
                    }

                    continuation.resume(returning: UIImage(cgImage: cgImage))
                }
            }
        }
        
        private func loadVideoFileURL(provider: NSItemProvider) async throws -> URL {
            try await withCheckedThrowingContinuation { continuation in
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let url = url else {
                        continuation.resume(throwing: URLError(.badURL))
                        return
                    }
                    
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension(url.pathExtension)
                    
                    do {
                        try FileManager.default.copyItem(at: url, to: tempURL)
                        continuation.resume(returning: tempURL)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
