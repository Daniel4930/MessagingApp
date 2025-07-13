//
//  LinkMetadataService.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/12/25.
//

import UIKit
import LinkPresentation

struct FetchMetaDataResponse {
    let title: String?
    let description: String?
    let image: UIImage?
}

enum FetchMetaDataError: Error {
    case noData(String)
    case badUrl(String)
    case fetchError(Error)
}

class LinkMetadataService {
    private func createUrlRequest(urlString: String) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        let request = URLRequest(url: url)
        
        return request
    }
    
    func getMetaDataFromUrl(urlString: String, completionHandler: @escaping(Result<FetchMetaDataResponse, FetchMetaDataError>) -> Void) {
        if let urlRequest = createUrlRequest(urlString: urlString) {
            let metaDataProvider = LPMetadataProvider()
            metaDataProvider.startFetchingMetadata(for: urlRequest) { metaData, error in
                if let error = error {
                    completionHandler(.failure(.fetchError(error)))
                    return
                }
                
                guard let metaData = metaData else {
                    completionHandler(.failure(.noData("No meta data")))
                    return
                }
                let title = metaData.title
                let description = metaData.value(forKey: "_summary") as? String
                
                if let iconProvider = metaData.imageProvider {
                    let _ = iconProvider.loadDataRepresentation(for: .image) { imageData, error in
                        var image: UIImage? = nil
                        if let imageData = imageData {
                            image = UIImage(data: imageData)
                        }
                        completionHandler(.success(FetchMetaDataResponse(title: title, description: description, image: image)))
                    }
                } else {
                    completionHandler(.success(FetchMetaDataResponse(title: title, description: description, image: nil)))
                }
            }
        } else {
            completionHandler(.failure(.badUrl("Bad url")))
        }
    }
}
