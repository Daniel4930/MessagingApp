//
//  MessageViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//

import CoreData

enum MessageLocation {
    case channel
    case dm
}

class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private let sharedContainerInstance = PersistenceContainer.shared
    
    init() {
        fetchMessages()
    }
    
    func fetchMessages() {
        let request = NSFetchRequest<Message>(entityName: "Message")
        
        do {
            messages = try sharedContainerInstance.context.fetch(request)
        } catch let error {
            fatalError("Couldn't fetch expenses with error: \(error.localizedDescription)")
        }
    }
    
    func addMessage(userId: UUID, text: String?, imageData: [ImageData]?, files: [FileData]?, location: MessageLocation, reaction: String?, replyMessageId: UUID?, forwardMessageId: UUID?, edited: Bool) {
        let message = Message(context: sharedContainerInstance.context)
        message.id = UUID()
        message.userId = userId
        message.date = Date()
        message.text = text
        message.reaction = reaction
        message.replyMessageId = replyMessageId
        message.forwardMessageId = forwardMessageId
        message.edited = edited
        
        if let imageData = imageData {
            message.images = NSSet(array: imageData)
        }
        if let files = files {
            message.files = NSSet(array: files)
        }
        switch location {
        case .channel:
            message.location = "channel"
        case .dm:
            message.location = "dm"
        }
        
        sharedContainerInstance.save()
        fetchMessages()
    }
}
