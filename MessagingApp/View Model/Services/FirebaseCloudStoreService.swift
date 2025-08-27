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

enum FirebaseCloudStoreCollection: String {
    case users = "users"
    case channels = "channels"
}

class FirebaseCloudStoreService {
    static let shared = FirebaseCloudStoreService()
    let db = Firestore.firestore(app: FirebaseApp.app()!, database: "messaging-app")
    
    init() {
        addListener()
    }
    
    private func encodeJSON<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(value)
            
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
    
    private func addListener() {
        db.collection(FirebaseCloudStoreCollection.users.rawValue).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
              print("Error fetching documents: \(error!)")
              return
            }
            
            for document in documents {
                print(document["aboutMe"] ?? "")
            }
        }
    }
    
    func addDocument<T: Encodable>(collection: FirebaseCloudStoreCollection.RawValue, documentId: String?, data: T) async -> String? {
        guard let jsonString = encodeJSON(data) else { return nil }
        guard let dataDict = convertJSONToDictionary(jsonString: jsonString) else { return nil }
        
        do {
            if let documentId {
                try await db.collection(collection).document(documentId).setData(dataDict)
                print("Document successfully written!")
            } else {
                let document = db.collection(collection).document()
                try await document.setData(dataDict)
                print("Document successfully written!")
                return document.documentID
            }
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }
        return nil
    }
    
    func updateData(collection: FirebaseCloudStoreCollection.RawValue, documentId: String, newData: [String: Any]) async -> Result<Void, FirebaseCloudStoreUpdateDataError> {
        do {
            try await db.collection(collection).document(documentId).updateData(newData)
            return Result.success(())
        } catch {
            return Result.failure(FirebaseCloudStoreUpdateDataError.updateFailed(error.localizedDescription))
        }
    }
    
    func fetchData<T: Decodable>(collection: FirebaseCloudStoreCollection.RawValue, ids: [String]) async -> [T] {
        guard !ids.isEmpty else { return [] }

        let chunkSize = 10
        let chunks = stride(from: 0, to: ids.count, by: chunkSize).map {
            Array(ids[$0..<min($0 + chunkSize, ids.count)])
        }
        
        var data: [T] = []

        await withTaskGroup(of: [T].self) { group in
            for chunk in chunks {
                group.addTask {
                    do {
                        let snapshot = try await self.db.collection(collection).whereField(FieldPath.documentID(), in: chunk).getDocuments()
                        return snapshot.documents.compactMap { try? $0.data(as: T.self) }
                    } catch {
                        print("Error fetching data chunk: \(error.localizedDescription)")
                        return []
                    }
                }
            }

            for await chunkOfData in group {
                data.append(contentsOf: chunkOfData)
            }
        }
        return data
    }
    
    func fetchUser(email: String) async -> UserInfo? {
        do {
            let snapshot = try await db.collection(FirebaseCloudStoreCollection.users.rawValue).whereField("email", isEqualTo: email).getDocuments()
            
            if let document = snapshot.documents.first {
                let user = try document.data(as: UserInfo.self)
                return user
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func checkIfUsernameExists(username: String) async -> Bool? {
        do {
            let snapshot = try await db.collection(FirebaseCloudStoreCollection.users.rawValue).whereField("userName", isEqualTo: username).getDocuments()
            
            return !snapshot.documents.isEmpty
        } catch {
            print("Error checking user's existing: \(error.localizedDescription)")
        }
        return false
    }
}
