
import SwiftUI

struct NotificationView: View {
    private let currentUserId: String?
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    init(userId: String?) {
        self.currentUserId = userId
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Notifications")
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title2.bold())
                .padding()
                .overlay(alignment: .bottom) {
                    DividerView()
                }
            
            ScrollView {
                if currentUserId == nil {
                    Text("Can't load notification")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(notificationViewModel.notifications) { notification in
                        var attributedString: AttributedString {
                            var result = AttributedString(notification.senderName)
                            result.font = .headline.bold()
                            return result
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text(attributedString + " sent you a friend request")
                                    .lineLimit(1)
                                    .layoutPriority(1)
                                Spacer()
                                if let timestamp = notification.timestamp {
                                    Text(notificationViewModel.formatNotificationTimestamp(time: timestamp.dateValue()))
                                        .font(.footnote)
                                }
                            }
                            
                            HStack {
                                Spacer()
                                Button("Accept") {
                                    Task {
                                        await acceptFriendRequestAction(notification: notification)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.capsule)
                                Spacer()
                                Button("Decline") {
                                    Task {
                                        await declineFriendRequestAction(notification: notification)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.capsule)
                                Spacer()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray)
                                .brightness(-0.4)
                        )
                        .padding(.bottom)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            if let currentUserId {
                notificationViewModel.setUserId(currentUserId)
            }
        }
    }
}
extension NotificationView {
    func acceptFriendRequestAction(notification: NotificationContent) async {
        do {
            let sender = await FirebaseCloudStoreService.shared.fetchUserByUsername(username: notification.senderName)
            
            guard let currentUserId = currentUserId else {
                print("Current user's id is nil")
                return
            }
            
            guard let sender = sender else {
                print("Sender is nil")
                return
            }
            guard let senderId = sender.id else {
                print("Sender id is nil")
                return
            }
            
            //Update new friend's document
            var senderFriends = sender.friends
            if !senderFriends.contains(currentUserId) {
                senderFriends.append(currentUserId)
                let senderUpdate: [String: Any] = [
                    "friends": senderFriends
                ]
                try await FirebaseCloudStoreService.shared.updateData(collection: .users, documentId: senderId, newData: senderUpdate)
            }
            
            //Update current user's document
            var currentUserFriends = userViewModel.user?.friends ?? []
            if !currentUserFriends.contains(senderId) {
                currentUserFriends.append(senderId)
                let currentUserUpdate: [String: Any] = [
                    "friends": currentUserFriends
                ]
                try await FirebaseCloudStoreService.shared.updateData(collection: .users, documentId: currentUserId, newData: currentUserUpdate)
            }
            
            //Delete the notification
            guard let notificationId = notification.id else {
                print("Notification id is nil")
                return
            }
            try await FirebaseCloudStoreService.shared.deleteDocument(collection: .notifications, documentId: notificationId)
            
            guard let index = notificationViewModel.notifications.firstIndex(where: {$0 == notification}) else {
                print("Notification index is nil")
                return
            }
            notificationViewModel.notifications.remove(at: index)
            
        } catch {
            print("Error update user's friend list. \(error.localizedDescription)")
        }
    }
    
    func declineFriendRequestAction(notification: NotificationContent) async {
        do {
            guard let notificationId = notification.id else {
                print("Notification id is nil")
                return
            }
            try await FirebaseCloudStoreService.shared.deleteDocument(collection: .notifications, documentId: notificationId)
            
            guard let index = notificationViewModel.notifications.firstIndex(where: {$0 == notification}) else {
                print("Notification index is nil")
                return
            }
            notificationViewModel.notifications.remove(at: index)
        } catch {
            print("Error removing notification. \(error.localizedDescription)")
        }
    }
}
