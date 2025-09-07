//
//  CustomPhotoPickerView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/6/25.
//

import SwiftUI
import PhotosUI
import AVFoundation

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
                    print("No identifier")
                    return
                }
                
                let provider = result.itemProvider
                if provider.registeredTypeIdentifiers.isEmpty { continue }
                
                if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                        guard error == nil else {
                            print("Error loading file: \(error!)")
                            return
                        }
                        guard let url else {
                            print("No URL returned")
                            return
                        }

                        let asset = AVURLAsset(url: url)

                        Task {
                            do {
                                // 1. Load duration
                                let duration = try await asset.load(.duration).seconds
                                let result = try await self.extractVideoData(from: url)
                                var videoData: Data?
                                
                                switch result {
                                case .success(let data):
                                    videoData = data
                                case .failure(let error):
                                    print("Failed to get video data \(error.localizedDescription)")
                                }

                                // 2. Generate thumbnail
                                let imageGenerator = AVAssetImageGenerator(asset: asset)
                                imageGenerator.appliesPreferredTrackTransform = true
                                imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, cgImage, _, _, error in
                                    
                                    guard error == nil else {
                                        print("Failed to generate CGImage \(error?.localizedDescription ?? "Unknown error")")
                                        return
                                    }
                                    
                                    guard let cgImage = cgImage else {
                                        print("CGImage is nil")
                                        return
                                    }
                                    
                                    guard let videoData = videoData else {
                                        print("VideoData is nil")
                                        return
                                    }
                                    
                                    // 3. Get filename
                                    let filename = url.lastPathComponent
                                    
                                    // 4. Build your UploadedFile
                                    let uploadedFile = UploadedFile(
                                        identifier: identifier,
                                        fileType: .video,
                                        photoInfo: nil,
                                        videoInfo: VideoFile(
                                            name: filename,
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
                            }
                        }
                    }
                }

                else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    Task {
                        do {
                            let photoData = try await loadData(provider: provider)
                            
                            guard let uiImage = UIImage(data: photoData) else {
                                print("Failed to convert to uiImage")
                                return
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
                        } catch let error as LoadFileError {
                            switch error {
                            case .loadDataError:
                                print("Failed to load image data")
                            case .urlError:
                                print("Failed to get image url")
                            }
                        } catch {
                            print("Unexpected error: \(error)")
                        }
                    }
                }
            }
        }
        
        private func loadFileURL(provider: NSItemProvider) async throws -> URL {
            let data = try await loadData(provider: provider)
            guard let url = URL(dataRepresentation: data, relativeTo: nil) else { throw LoadFileError.urlError }
            
            return url
        }
        
        private func loadData(provider: NSItemProvider) async throws -> Data {
            guard let data = try await provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) as? Data else {
                throw LoadFileError.loadDataError
            }
            return data
        }

        func extractVideoData(from url: URL) async throws -> Result<Data?, Error> {
            let asset = AVURLAsset(url: url)

            // Load necessary asset keys asynchronously
            let tracks = try await asset.load(.tracks)
            
            var error: NSError?
            let status = asset.status(of: .tracks)

            guard status == .loaded([]) else {
                return .failure(error ?? NSError(domain: "AVURLAssetError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot load video tracks"]))
            }

            guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
                return .failure(NSError(domain: "AVURLAssetError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No video track found."]))
            }

            do {
                let assetReader = try AVAssetReader(asset: asset)
                let outputSettings: [String: Any] = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, // Example pixel format
                    kCVPixelBufferIOSurfacePropertiesKey as String: [:] // Optional: for Metal/OpenGL interop
                ]
                let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)

                if assetReader.canAdd(videoOutput) {
                    assetReader.add(videoOutput)
                } else {
                    return .failure(NSError(domain: "AVURLAssetError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot add video output to asset reader."]))
                }

                assetReader.startReading()

                var videoData = Data()
                while let sampleBuffer = videoOutput.copyNextSampleBuffer() {
                    // Process the sample buffer to extract pixel data
                    if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
                        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
                        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
                        let height = CVPixelBufferGetHeight(imageBuffer)

                        let bufferSize = bytesPerRow * height
                        let bufferData = Data(bytes: baseAddress!, count: bufferSize)
                        videoData.append(bufferData) // Append raw pixel data

                        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
                    }
                    CMSampleBufferInvalidate(sampleBuffer) // Release sample buffer
                }

                assetReader.cancelReading() // Stop reading after processing
                return .success(videoData)

            } catch {
                return .failure(error)
            }
        }

    }
}
