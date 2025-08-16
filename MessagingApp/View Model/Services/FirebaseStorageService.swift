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
        }
        
        return storageRef.child(path)
    }
    
    func uploadFileToBucket(reference: StorageReference, url: URL) {
        reference.putFile(from: url, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload file to bucket failed: \(error.localizedDescription)")
                return
            }
            
            guard let metadata = metadata else {
                print("Upload file failed: Metadata is nil")
                return
            }
            print("Uploaded file size: \(metadata.size)")
            print("uploaded content-type: \(metadata.contentType ?? "Unknown content-type")")
            
            reference.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download url: \(error.localizedDescription)")
                    return
                }
                if let downloadUrl = url {
                    print("Download URL: \(downloadUrl)")
                }
            }
        }
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
