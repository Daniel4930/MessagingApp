//
//  SelectorViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/2/25.
//

import Foundation
import Photos

@MainActor
final class SelectorViewModel: ObservableObject {
    @Published var accessStatus: PhotoLibraryAccessStatus?
    @Published var assets: [PHAsset] = []
    @Published var assetsDict: [String: PHAsset] = [:]
    
    func handlePhotoLibraryAccessRequest() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            Task { @MainActor in
                switch status {
                case .authorized:
                    self.accessStatus = .fullAccess
                case .limited:
                    self.accessStatus = .limitedAccess
                case .denied:
                    self.accessStatus = .denied
                case .restricted:
                    self.accessStatus = .restricted
                case .notDetermined:
                    break
                @unknown default:
                    fatalError("Unknown authorization status.")
                }
            }
        }
    }
    
    func getPhotosAndVideosAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 200
        let results: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        DispatchQueue.main.async {
            if results.count > 0 {
                for i in 0..<results.count {
                    let asset = results[i]
                    if self.assetsDict[asset.localIdentifier] == nil {
                        self.assetsDict[asset.localIdentifier] = asset
                    }
                }
                
                // Update assets array with sorted values from dictionary
                self.assets = self.assetsDict.values.sorted { asset1, asset2 in
                    guard let date1 = asset1.creationDate,
                          let date2 = asset2.creationDate else {
                        return false
                    }
                    return date1 > date2
                }
            }
        }
    }
    
    func refreshLibraryAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        DispatchQueue.main.async {
            self.assets = []
            if results.count > 0 {
                for i in 0..<results.count {
                    self.assets.append(results[i])
                }
            }
        }
    }
}
