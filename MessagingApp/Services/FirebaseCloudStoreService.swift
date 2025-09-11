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
    case notifications = "notifications"
}

class FirebaseCloudStoreService {
    static let shared = FirebaseCloudStoreService()
    let db = Firestore.firestore(app: FirebaseApp.app()!, database: "messaging-app")

    // MARK: - Generic CRUD Operations (Refactored)

    func addDocument<T: Encodable>(collection: FirebaseCloudStoreCollection, documentId: String? = nil, data: T, additionalData: [String:Any]?) async throws -> String {
        do {
            var dataDict = try Firestore.Encoder().encode(data)
            if let additionalData = additionalData {
                for key in additionalData.keys {
                    dataDict[key] = additionalData[key]
                }
            }

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
    
    func deleteDocument(collection: FirebaseCloudStoreCollection, documentId: String) async throws {
        do {
            try await db.collection(collection.rawValue).document(documentId).delete()
        } catch {
            throw FirebaseError.operationFailed("Error removing document: \(error.localizedDescription)")
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
    func listenForUser(userId: String) -> AsyncThrowingStream<User, Error> {
        let stream = AsyncThrowingStream(User.self) { continuation in
            let listener = db.collection(FirebaseCloudStoreCollection.users.rawValue)
                .document(userId)
                .addSnapshotListener { documentSnapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let document = documentSnapshot else {
                        continuation.finish(throwing: NSError(domain: "FirebaseCloudStoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document snapshot was nil."]))
                        return
                    }
                    
                    do {
                        let user = try document.data(as: User.self)
                        continuation.yield(user)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
        return stream
    }

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
    func fetchLastMessages(channelId: String, limit: Int = 10) async throws -> ([Message], DocumentSnapshot?) {
        let snapshot = try await db.collection(FirebaseCloudStoreCollection.channels.rawValue).document(channelId).collection(FirebaseCloudStoreCollection.messages.rawValue)
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        let messages = snapshot.documents.compactMap { try? $0.data(as: Message.self) }
        return (messages.reversed(), snapshot.documents.last)
    }

    func listenForMessageUpdates(channelId: String, from startDate: Date? = nil) -> AsyncThrowingStream<(added: [Message], modified: [Message], removed: [Message]), Error> {
        return AsyncThrowingStream { continuation in
            var query: Query = db.collection(FirebaseCloudStoreCollection.channels.rawValue).document(channelId).collection(FirebaseCloudStoreCollection.messages.rawValue)

            if let startDate = startDate {
                query = query.whereField("date", isGreaterThanOrEqualTo: startDate)
            }

            let listener = query.addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    guard let snapshot = querySnapshot else {
                        continuation.yield(([], [], []))
                        return
                    }

                    var addedMessages: [Message] = []
                    var modifiedMessages: [Message] = []
                    var removedMessages: [Message] = []

                    snapshot.documentChanges.forEach { diff in
                        guard let message = try? diff.document.data(as: Message.self) else {
                            return
                        }
                        switch diff.type {
                        case .added:
                            addedMessages.append(message)
                        case .modified:
                            modifiedMessages.append(message)
                        case .removed:
                            removedMessages.append(message)
                        }
                    }
                    continuation.yield((addedMessages, modifiedMessages, removedMessages))
                }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    /// Fetches an older batch of messages for pagination.
    func fetchMoreMessages(channelId: String, lastDocumentSnapshot: DocumentSnapshot, limit: Int = 10) async throws -> ([Message], DocumentSnapshot?) {
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
        
        var newMessage = message
        newMessage.id = messageRef.documentID
        guard let lastMessage = LastMessage(from: newMessage) else {
            throw FirebaseError.encodingFailed
        }
        
        // 2. Update the parent channel document
        let channelRef = db.collection(FirebaseCloudStoreCollection.channels.rawValue).document(channelId)
        let lastMessageData = try Firestore.Encoder().encode(lastMessage)
        batch.updateData(["lastMessage": lastMessageData, "lastActivity": message.date as Any], forDocument: channelRef)
        
        try await batch.commit()
    }
    
    func updateMessageText(channleId: String, messageId: String, text: String) async throws {
        do {
            try await db
                .collection(FirebaseCloudStoreCollection.channels.rawValue)
                .document(channleId)
                .collection(FirebaseCloudStoreCollection.messages.rawValue)
                .document(messageId)
                .setData(["text": text, "edited": true], mergeFields: ["text", "edited"])
        } catch {
            throw FirebaseError.operationFailed("Failed to update message text \(error.localizedDescription)")
        }
    }
    
    func deleteMessage(messageId: String, channelId: String) {
        db
        .collection(FirebaseCloudStoreCollection.channels.rawValue)
        .document(channelId)
        .collection(FirebaseCloudStoreCollection.messages.rawValue)
        .document(messageId)
        .delete()
    }

    // MARK: - NotificationContent Functions
    func fetchNotifications(userId: String) async throws -> [NotificationContent]? {
        
        do {
            let snapshot = try await db.collection(FirebaseCloudStoreCollection.notifications.rawValue)
                .whereField("recipientId", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .getDocuments()
            
            return snapshot.documents.compactMap({ try? $0.data(as: NotificationContent.self) })
        } catch {
            print("Error fetching notifications \(error.localizedDescription)")
        }
        return nil
    }
    
    func fetchFriendRequest(recipientId: String, senderName: String) async throws -> [NotificationContent]? {
        
        do {
            let snapshot = try await db.collection(FirebaseCloudStoreCollection.notifications.rawValue)
                .whereField("type", isEqualTo: NotificationType.friendRequest.rawValue)
                .whereField("recipientId", isEqualTo: recipientId)
                .whereField("senderName", isEqualTo: senderName)
                .getDocuments()
            
            return snapshot.documents.compactMap({ try? $0.data(as: NotificationContent.self) })
        } catch {
            print("Error fetching friend request \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - User Functions (Unchanged)
        
    func fetchUserByEmail(email: String) async -> User? {
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
    
    func fetchUserByUsername(username: String) async -> User? {
        do {
            let snapshot = try await db.collection(FirebaseCloudStoreCollection.users.rawValue).whereField("userName", isEqualTo: username).getDocuments()
            
            if let document = snapshot.documents.first {
                return try document.data(as: User.self)
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
        return nil
    }
    
    func updateUserFCMToken(userId: String, token: String) async {
        do {
            try await updateData(collection: .users, documentId: userId, newData: ["fcmToken": token])
        } catch {
            print("Error updating FCM token: \(error.localizedDescription)")
        }
    }
}
