//
//  FirebaseService.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/15/25.
//

import Foundation
import FirebaseStorage

enum FirebaseStorageFolder {
    case images
    case videos
    case files
    case icons
}

enum FirebaseStorageUploadError: Error {
    case uploadFailed(String)
    case getDownloadUrlFailed(String)
    case noDownloadUrl
}

enum FirebaseDownloadFileError: Error {
    case downloadError(String)
    case noUrlError
}

struct Config: Decodable {
    let STORAGE_BUCKET: String
}

class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    static var bucketName: String {
        if let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist"), let data = try? Data(contentsOf: url) {
            let decoder = PropertyListDecoder()
            if let config = try? decoder.decode(Config.self, from: data) {
                return config.STORAGE_BUCKET
            }
        }
        fatalError("Failed to get bucket name")
    }
    let storage: Storage
    let storageRef: StorageReference
    
    init() {
        self.storage = Storage.storage(url: "gs://\(FirebaseStorageService.bucketName)")
        self.storageRef = self.storage.reference()
    }
    
    func createChildReference(folder: FirebaseStorageFolder, fileName: String) -> StorageReference {
        var path: String = ""
        
        switch folder {
        case .images:
            path = "images/\(fileName)"
        case .icons:
            path = "icons/\(fileName)"
        case .files:
            path = "files/\(fileName)"
        case .videos:
            path = "videos/\(fileName)"
        }
        
        return storageRef.child(path)
    }
    
    func uploadFileToBucket(reference: StorageReference, url: URL, completion: @escaping (Result<URL, FirebaseStorageUploadError>) -> Void) {
        reference.putFile(from: url, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(FirebaseStorageUploadError.uploadFailed(error.localizedDescription)))
            }
            
            reference.downloadURL { url, error in
                if let error = error {
                    completion(.failure(FirebaseStorageUploadError.getDownloadUrlFailed(error.localizedDescription)))
                    return
                }
                if let downloadUrl = url {
                    completion(.success(downloadUrl))
                } else {
                    completion(.failure(FirebaseStorageUploadError.noDownloadUrl))
                }
            }
        }
    }
    
    func uploadDataToBucket(reference: StorageReference, data: Data, completion: @escaping (Result<URL, FirebaseStorageUploadError>) -> Void) -> StorageUploadTask {
        let uploadTask = reference.putData(data) { _, error in
            if let error = error {
                completion(.failure(FirebaseStorageUploadError.uploadFailed(error.localizedDescription)))
                return
            }
            
            reference.downloadURL { url, error in
                if let error = error {
                    completion(.failure(FirebaseStorageUploadError.getDownloadUrlFailed(error.localizedDescription)))
                    return
                }
                if let downloadUrl = url {
                    completion(.success(downloadUrl))
                } else {
                    completion(.failure(FirebaseStorageUploadError.noDownloadUrl))
                }
            }
        }
        return uploadTask
    }
    
    func downloadFileFromBucket(reference: StorageReference, completion: @escaping (Result<URL, FirebaseDownloadFileError>) -> Void) {
        reference.downloadURL { url, error in
            if let error = error {
                completion(.failure(.downloadError(error.localizedDescription)))
            } else {
                if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(.noUrlError))
                }
            }
        }
    }
}
