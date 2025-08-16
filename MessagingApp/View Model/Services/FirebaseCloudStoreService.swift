//
//  FirebaseCloudStoreService.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/15/25.
//

import FirebaseFirestore
import FirebaseCore

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
    
    private func checkUserAlreadyExist(email: String) async -> Bool {
        do {
            let querySnapshot = try await db.collection("users").whereField("email", isEqualTo: email).getDocuments()
            
            return querySnapshot.documents.isEmpty
            
        } catch {
            print("Failed to check user existent: \(error.localizedDescription)")
        }
        
        return false
    }
    
    func addUser(user: UserInfo) async {
        guard await checkUserAlreadyExist(email: user.email) else {
            print("User's email already exists")
            return
        }
        guard let jsonString = encodeJSON(user: user) else { return }
        guard let userDict = convertJSONToDictionary(jsonString: jsonString) else { return }
        
        do {
            let ref = try await db.collection("users").addDocument(data: userDict)
            
            print("Document added with ID: \(ref.documentID)")
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }
    }
    
    func loginUser(email: String, password: String) async -> Bool {
        guard await checkUserAlreadyExist(email: email) else {
            print("User's email already exists")
            return false
        }
        
        do {
            let querySnapshot = try await db.collection("users").whereField("email", isEqualTo: email).whereField("password", isEqualTo: password).getDocuments()
            
            for document in querySnapshot.documents {
                print("\(document.documentID) => \(document.data())")
            }
            
            return true
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return false
    }
}
