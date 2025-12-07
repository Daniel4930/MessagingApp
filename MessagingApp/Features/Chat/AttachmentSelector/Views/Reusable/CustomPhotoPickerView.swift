//
//  CustomPhotoPickerView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/6/25.
//

import SwiftUI
import PhotosUI
import AVFoundation

enum PhotoPickerResultError: Error {
    case noURL
    case providerError(Error)
    case copyFailed(Error)
    case durationLoadFailed
    case videoDataMissing
    case thumbnailGenerationFailed(Error?)
    case imageDataMissing
    case imageConversionFailed
}

struct CustomPhotoPickerView<Content: View>: View {
    @Binding var height: CGFloat
    let minHeight: CGFloat
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    let photoPickerContent: () -> Content
    @State private var showPhotoPicker = false
    
    var body: some View {
        photoPickerContent()
            .sheet(isPresented: $showPhotoPicker) {
                PickerViewController(messageComposerViewModel: messageComposerViewModel, height: $height, minHeight: minHeight)
            }
            .onTapGesture {
                showPhotoPicker.toggle()
            }
    }
}

struct PickerViewController: UIViewControllerRepresentable {
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    @Binding var height: CGFloat
    let minHeight: CGFloat
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    
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
                    print("Asset has no identifier")
                    self.parent.alertViewModel.presentAlert(message: "Unknown error when picked asset from library", type: .error)
                    return
                }
                    
                let provider = result.itemProvider
                if provider.registeredTypeIdentifiers.isEmpty { continue }
                
                if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                        guard error == nil else {
                            print("Failed to load video file representation")
                            return
                        }
                        
                        guard let url = url else {
                            return
                        }
                        
                        Task {
                            do {
                                let avUrlAsset = AVURLAsset(url: url)
                                let duration = try await CMTimeGetSeconds(avUrlAsset.load(.duration))

                                let imageGenerator = AVAssetImageGenerator(asset: avUrlAsset)
                                imageGenerator.appliesPreferredTrackTransform = true
                                imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, cgImage, _, _, error in

                                    guard error == nil, let cgImage = cgImage else {
                                        print(PhotoPickerResultError.thumbnailGenerationFailed(error))
                                        return
                                    }
                                    
                                    let fetchPHAssetResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
                                    guard let photoLibraryAsset = fetchPHAssetResult.firstObject else {
                                        print("Failed to get PHAsset")
                                        return
                                    }

                                    let uploadedFile = UploadedFile(
                                        identifier: identifier,
                                        fileType: .video,
                                        photoInfo: nil,
                                        videoInfo: VideoFile(
                                            duration: duration,
                                            thumbnail: UIImage(cgImage: cgImage),
                                            videoAsset: photoLibraryAsset
                                        ),
                                        fileInfo: nil
                                    )

                                    DispatchQueue.main.async {
                                        self.parent.messageComposerViewModel.selectionData.append(uploadedFile)
                                    }
                                }
                            } catch {
                                print("Failed to process video: \(error)")
                                await self.parent.alertViewModel.presentAlert(message: "Failed to pick videos from library", type: .error)
                            }
                        }
                    }
                }

                
                else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    let _ = provider.loadDataRepresentation(for: UTType.image) { data, error in
                        Task {
                            do {
                                if let error { throw PhotoPickerResultError.providerError(error) }
                                guard let data else { throw PhotoPickerResultError.imageDataMissing }
                                guard let uiImage = UIImage(data: data) else {
                                    throw PhotoPickerResultError.imageConversionFailed
                                }
                                
                                let photoInfo = PhotoFile(image: uiImage)
                                let uploadedFile = UploadedFile(
                                    identifier: identifier,
                                    fileType: .photo,
                                    photoInfo: photoInfo,
                                    videoInfo: nil,
                                    fileInfo: nil
                                )
                                
                                DispatchQueue.main.async {
                                    self.parent.messageComposerViewModel.selectionData.append(uploadedFile)
                                }
                            } catch {
                                print("Failed to process image: \(error)")
                                await self.parent.alertViewModel.presentAlert(message: "Failed to pick photos from library", type: .error)
                            }
                        }
                    }
                }
            }
        }

        
    }
}
