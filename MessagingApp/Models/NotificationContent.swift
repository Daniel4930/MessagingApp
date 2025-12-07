
import Foundation
import FirebaseFirestore

enum NotificationType: String, Codable {
    case friendRequest
}

struct NotificationContent: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let recipientId: String
    let senderName: String
    let type: NotificationType
    let channelId: String?
    var isRead: Bool
    @ServerTimestamp var timestamp: Timestamp?
}
