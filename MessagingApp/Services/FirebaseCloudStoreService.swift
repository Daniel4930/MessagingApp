//
//  FirebaseCloudStoreService.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/15/25.
//

import FirebaseFirestore
import FirebaseCore

enum FirebaseError: Error {
    case operationFailed(String)
    case encodingFailed
}

enum FirebaseCloudStoreCollection: String {
    case users = "users"
    case channels = "channels"
    case messages = "messages"
}

class FirebaseCloudStoreService {
    static let shared = FirebaseCloudStoreService()
    let db = Firestore.firestore(app: FirebaseApp.app()!, database: "messaging-app")

    // MARK: - Generic CRUD Operations (Refactored)

    func addDocument<T: Encodable>(collection: FirebaseCloudStoreCollection, documentId: String? = nil, data: T) async throws -> String {
        do {
            let dataDict = try Firestore.Encoder().encode(data)

            let collectionRef = db.collection(collection.rawValue)
            if let documentId = documentId {
                try await collectionRef.document(documentId).setData(dataDict)
                return documentId
            } else {
                let newDocRef = collectionRef.document()
                try await newDocRef.setData(dataDict)
                return newDocRef.documentID
            }
        } catch {
            throw FirebaseError.operationFailed("Error adding document: \(error.localizedDescription)")
        }
    }

    func updateData(collection: FirebaseCloudStoreCollection, documentId: String, newData: [String: Any]) async throws {
        do {
            try await db.collection(collection.rawValue).document(documentId).updateData(newData)
        } catch {
            throw FirebaseError.operationFailed("Error updating document: \(error.localizedDescription)")
        }
    }
    
    func fetchData<T: Decodable>(collection: FirebaseCloudStoreCollection, ids: [String]) async -> [T] {
        guard !ids.isEmpty else { return [] }

        do {
            let snapshot = try await db.collection(collection.rawValue).whereField(FieldPath.documentID(), in: ids).getDocuments()
            return snapshot.documents.compactMap { try? $0.data(as: T.self) }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Messaging Functions (New Implementation)

    /// Listens for real-time updates to a user's channels, ordered by last activity.
    func listenForUserChannels(userId: String) -> AsyncThrowingStream<[Channel], Error> {
        return AsyncThrowingStream { continuation in
            let listener = db.collection(FirebaseCloudStoreCollection.channels.rawValue)
                .whereField("memberIds", arrayContains: userId)
                .order(by: "lastActivity", descending: true)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    guard let documents = querySnapshot?.documents else {
                        continuation.yield([])
                        return
                    }
                    let channels = documents.compactMap { try? $0.data(as: Channel.self) }
                    continuation.yield(channels)
                }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    /// Listens for the latest messages in a specific channel.
    func listenForMessages(channelId: String, limit: Int = 10) -> AsyncThrowingStream<(messages: [Message], documentSnapshot: DocumentSnapshot?), Error> {
        return AsyncThrowingStream { continuation in
            let listener = db.collection(FirebaseCloudStoreCollection.channels.rawValue).document(channelId).collection(FirebaseCloudStoreCollection.messages.rawValue)
                .order(by: "date", descending: false)
                .limit(to: limit)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    guard let documents = querySnapshot?.documents else {
                        continuation.yield(([], nil))
                        return
                    }
                    let messages = documents.compactMap { try? $0.data(as: Message.self) }
                    continuation.yield((messages.reversed(), documents.last))
                }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    /// Fetches an older batch of messages for pagination.
    func fetchMoreMessages(channelId: String, lastDocumentSnapshot: DocumentSnapshot, limit: Int = 20) async throws -> ([Message], DocumentSnapshot?) {
        let snapshot = try await db.collection(FirebaseCloudStoreCollection.channels.rawValue).document(channelId).collection(FirebaseCloudStoreCollection.messages.rawValue)
            .order(by: "date", descending: true)
            .start(afterDocument: lastDocumentSnapshot)
            .limit(to: limit)
            .getDocuments()
        
        let messages = snapshot.documents.compactMap { try? $0.data(as: Message.self) }
        return (messages.reversed(), snapshot.documents.last)
    }

    /// Sends a message and atomically updates the parent channel's last message and activity.
    func sendMessage(channelId: String, message: Message) async throws {
        guard let lastMessage = LastMessage(from: message) else {
            throw FirebaseError.encodingFailed
        }
        
        let batch = db.batch()
        
        // 1. Create the new message document in the subcollection
        let messageRef = db
            .collection(FirebaseCloudStoreCollection.channels.rawValue)
            .document(channelId)
            .collection(FirebaseCloudStoreCollection.messages.rawValue)
            .document()
        var messageData = try Firestore.Encoder().encode(message)
        messageData["date"] = FieldValue.serverTimestamp()
        batch.setData(messageData, forDocument: messageRef)
        
        // 2. Update the parent channel document
        let channelRef = db.collection(FirebaseCloudStoreCollection.channels.rawValue).document(channelId)
        let lastMessageData = try Firestore.Encoder().encode(lastMessage)
        batch.updateData(["lastMessage": lastMessageData, "lastActivity": message.date as Any], forDocument: channelRef)
        
        try await batch.commit()
    }

    // MARK: - User Functions (Unchanged)
    
    func fetchUser(email: String) async -> User? {
        do {
            let snapshot = try await db.collection(FirebaseCloudStoreCollection.users.rawValue).whereField("email", isEqualTo: email).getDocuments()
            if let document = snapshot.documents.first {
                return try document.data(as: User.self)
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
        return nil
    }
}

// Helper to create a LastMessage from a Message
extension LastMessage {
    init?(from message: Message) {
        self.senderId = message.senderId
        self.text = message.text
        self.timestamp = message.date!
    }
}
