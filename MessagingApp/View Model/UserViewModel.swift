//
//  UserViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import UIKit

enum DownloadImageError: Error {
    case invalidUrl
    case responseError(Int?)
}

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: UserInfo?
    @Published var userIcon: UIImage?
    @Published var friends: [UserInfo] = []
    
    func fetchCurrentUser(email: String) async {
        self.user = await FirebaseCloudStoreService.shared.fetchUser(email: email)
    }
    
    func fetchFriendInfo() async {
        if let user = user, !user.friends.isEmpty {
            self.friends = await FirebaseCloudStoreService.shared.fetchFriends(ids: user.friends)
        }
    }
    
//    func fetchIcon(urlString: String) async -> UIImage? {
//        do {
//            guard let url = URL(string: urlString) else {
//                throw DownloadImageError.invalidUrl
//            }
//            
//            let session = URLSession.shared
//            let urlRequest = URLRequest(url: url)
//            
//            let result = try await session.data(for: urlRequest)
//            guard let httpResponse = result.1 as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                if let httpResponse = result.1 as? HTTPURLResponse {
//                    throw DownloadImageError.responseError(httpResponse.statusCode)
//                } else {
//                    throw DownloadImageError.responseError(nil)
//                }
//            }
//            return UIImage(data: result.0)
//            
//        } catch let error as DownloadImageError {
//            switch error {
//            case .invalidUrl:
//                print("User icon's url is invalid")
//            case .responseError(let statusCode):
//                if let code = statusCode {
//                    print("Url's session gives a bad response when fetching user's icon with status code: \(code)")
//                } else {
//                    print("Url's session gives a bad response when fetching user's icon")
//                }
//            }
//        } catch {
//            print("Failed to fetch user's icon: \(error.localizedDescription)")
//        }
//        return nil
//    }
    
    func fetchUserByUsername(name: String) -> UserInfo? {
        if user?.userName == name {
            return user
        } else {
            return friends.first(where: { $0.userName == name })
        }
    }
}
