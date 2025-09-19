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
                        Task {
                            do {
                                if let error { throw PhotoPickerResultError.providerError(error) }
                                guard let url else { throw PhotoPickerResultError.noURL }
                                
                                // Copy to a safe location
                                let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                                do {
                                    if FileManager.default.fileExists(atPath: tmpURL.path) {
                                        try FileManager.default.removeItem(at: tmpURL)
                                    }
                                    try FileManager.default.copyItem(at: url, to: tmpURL)
                                } catch {
                                    throw PhotoPickerResultError.copyFailed(error)
                                }
                                
                                let asset = AVURLAsset(url: tmpURL)
                                let duration = try await CMTimeGetSeconds(asset.load(.duration))
                                
                                let result = try await self.extractVideoData(from: tmpURL)
                                guard case let .success(videoData?) = result else {
                                    throw PhotoPickerResultError.videoDataMissing
                                }
                                
                                // Generate thumbnail
                                let imageGenerator = AVAssetImageGenerator(asset: asset)
                                imageGenerator.appliesPreferredTrackTransform = true
                                imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, cgImage, _, _, error in
                                    guard error == nil else {
                                        print(PhotoPickerResultError.thumbnailGenerationFailed(error))
                                        return
                                    }
                                    guard let cgImage else {
                                        print(PhotoPickerResultError.thumbnailGenerationFailed(nil))
                                        return
                                    }
                                    
                                    let uploadedFile = UploadedFile(
                                        identifier: identifier,
                                        fileType: .video,
                                        photoInfo: nil,
                                        videoInfo: VideoFile(
                                            name: UUID().uuidString + ".mp4",
                                            duration: duration,
                                            videoData: videoData,
                                            thumbnail: UIImage(cgImage: cgImage)
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
                                
                                let photoInfo = PhotoFile(name: identifier, image: uiImage)
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

        func extractVideoData(from url: URL) async throws -> Result<Data?, Error> {
            do {
                let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mp4")
                
                guard let exportSession = AVAssetExportSession(
                    asset: AVURLAsset(url: url),
                    presetName: AVAssetExportPresetMediumQuality
                ) else {
                    return .success(nil)
                }
                
                try await exportSession.export(to: outputURL, as: .mp4)
                
                let data = try Data(contentsOf: outputURL)
                
                return .success(data)
            } catch {
                return .failure(error)
            }
        }
    }
}
