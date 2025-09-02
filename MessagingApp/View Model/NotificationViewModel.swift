
import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationContent] = []
    @Published var unreadCount: Int = 0
    private let cloudStoreService = FirebaseCloudStoreService.shared
    private var userId: String?
    
    private func fetchNotifications() {
        guard let userId = userId else { return }
        
        Task {
            guard let fetchedNotifications = try await cloudStoreService.fetchNotifications(userId: userId) else { return }
            notifications = fetchedNotifications
        }
    }

    func setUserId(_ userId: String) {
        self.userId = userId
        fetchNotifications()
    }
    
    func formatNotificationTimestamp(time: Date) -> String {
        let pastDate = Date().addingTimeInterval(time.timeIntervalSinceNow)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.dateTimeStyle = .numeric
        return formatter.string(for: pastDate)!
    }
    
    func setupNotificationContent(recipientId: String?, senderName: String, type: NotificationType, channelId: String?, isRead: Bool) -> NotificationContent? {
        guard let recipientId = recipientId else {
            print("Set up notification failed: RecipientId is nil")
            return nil
        }
        
        return NotificationContent(recipientId: recipientId, senderName: senderName, type: type, channelId: channelId, isRead: isRead)
    }
    
    func addNotification(notification: NotificationContent) async throws {
        do {
            let additionalData = [
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            let _ = try await cloudStoreService.addDocument(collection: FirebaseCloudStoreCollection.notifications, data: notification, additionalData: additionalData)
            
        } catch {
            throw error
        }
    }
}
