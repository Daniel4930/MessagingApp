//
//  FirebaseCloudStoreService.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/15/25.
//

import FirebaseFirestore
import FirebaseCore

enum FirebaseCloudStoreUpdateDataError: Error {
    case updateFailed(String)
}

class FirebaseCloudStoreService {
    static let shared = FirebaseCloudStoreService()
    let db = Firestore.firestore(app: FirebaseApp.app()!, database: "messaging-app")
    
    private func encodeJSON(user: UserInfo) -> String? {
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(user)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
        }
        return nil
    }
    
    private func convertJSONToDictionary(jsonString: String) -> [String: Any]? {
        if let data = jsonString.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print("Failed to covert JSON to dictionary: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    func addUser(user: UserInfo) async {
        guard let jsonString = encodeJSON(user: user) else { return }
        guard let userDict = convertJSONToDictionary(jsonString: jsonString) else { return }
        
        do {
            try await db.collection("users").document(user.id).setData(userDict)
            print("Document successfully written!")
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }
    }
    
    func fetchUser(email: String) async -> UserInfo? {
        do {
            let snapshot = try await db.collection("users").whereField("email", isEqualTo: email).getDocuments()
            
            if let document = snapshot.documents.first {
                let user = try? document.data(as: UserInfo.self)
                return user
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func fetchFriend(id: String) async -> UserInfo? {
        do {
            let snapshot = try await db.collection("users").whereField("id", isEqualTo: id).getDocuments()
            
            if let document = snapshot.documents.first {
                return try? document.data(as: UserInfo.self)
            }
        } catch {
            print("Error fetching a friend: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func checkIfUsernameExists(username: String) async -> Bool? {
        do {
            let snapshot = try await db.collection("users").whereField("userName", isEqualTo: username).getDocuments()
            
            return !snapshot.documents.isEmpty
        } catch {
            print("Error checking user's existing: \(error.localizedDescription)")
        }
        return false
    }
    
    func updateUser(documentId: String, newData: [String: Any]) async -> Result<Void, FirebaseCloudStoreUpdateDataError> {
        do {
            try await db.collection("users").document(documentId).updateData(newData)
            return Result.success(())
        } catch {
            return Result.failure(FirebaseCloudStoreUpdateDataError.updateFailed(error.localizedDescription))
        }
    }
}
