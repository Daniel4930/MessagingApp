//
//  UserViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import CoreData
import UIKit

enum OnlineStatus {
    case online
    case offline
    case invisible
    case doNotDisturb
    case idle
}

class UserViewModel: ObservableObject {
    @Published var user: User?
    private let sharedContainerInstance = PersistenceContainer.shared
    
    init() {
//        generateMockUser()
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        let request = NSFetchRequest<User>(entityName: "User")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "userName == %@", "phu" as NSString)
        
        do {
            let result = try sharedContainerInstance.context.fetch(request)
            if let firstUser = result.first {
                user = firstUser
            }
        } catch let error {
            fatalError("Failed to fetch user: \(error.localizedDescription)")
        }
    }
    
    func fetchUser(id: UUID) -> User? {
        let request = NSFetchRequest<User>(entityName: "User")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let result = try sharedContainerInstance.context.fetch(request)
            if let firstUser = result.first {
                return firstUser
            }
        } catch let error {
            fatalError("Failed to fetch user: \(error.localizedDescription)")
        }
        return nil
    }
    
    func fetchAllUsers() -> [User] {
        let request = NSFetchRequest<User>(entityName: "User")

        do {
            let result = try sharedContainerInstance.context.fetch(request)
            return result
        } catch let error {
            fatalError("Failed to fetch user: \(error.localizedDescription)")
        }
    }
    
    func generateMockUser() {
        let user1 = User(context: sharedContainerInstance.context)
        user1.id = UUID()
        user1.displayName = "Clyde"
        user1.userName = "clyde#0000"
        user1.icon = UIImage(named: "icon")?.pngData()
        user1.bannerColor = "none"
        user1.onlineStatus = "doNotDisturb"
        user1.registeredDate = Date()
        
        let user2 = User(context: sharedContainerInstance.context)
        user2.id = UUID()
        user2.displayName = "Unlimited"
        user2.userName = "phu"
        user2.icon = UIImage(named: "userIcon")?.pngData()
        user2.bannerColor = "none"
        user2.onlineStatus = "idle"
        user2.registeredDate = Date()
        user2.friends = NSSet(object: user1)
        
        sharedContainerInstance.save()
    }
}
