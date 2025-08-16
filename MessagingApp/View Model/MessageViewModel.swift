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
    
    func addMessage(userId: UUID, text: String?, images: [URL?], files: [URL?], videos: [URL?], location: MessageLocation, reaction: String?, replyMessageId: UUID?, forwardMessageId: UUID?, edited: Bool) {
        let message = Message(context: sharedContainerInstance.context)
        message.id = UUID()
        message.userId = userId
        message.date = Date()
        message.text = text
        message.reaction = reaction
        message.replyMessageId = replyMessageId
        message.forwardMessageId = forwardMessageId
        message.edited = edited
        
        let imageUrls: [ImageUrl] = images.compactMap { url in
            let imageUrl = ImageUrl(context: sharedContainerInstance.context)
            imageUrl.url = url
            return imageUrl
        }
        message.images = NSSet(array: imageUrls)
        
        
        let fileUrls: [FileUrl] = files.compactMap { url in
            let fileUrl = FileUrl(context: sharedContainerInstance.context)
            fileUrl.url = url
            return fileUrl
        }
        message.files = NSSet(array: fileUrls)
        
        let videoUrls: [VideoUrl] = videos.compactMap { url in
            let videoUrl = VideoUrl(context: sharedContainerInstance.context)
            videoUrl.url = url
            return videoUrl
        }
        message.videos = NSSet(array: videoUrls)

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
