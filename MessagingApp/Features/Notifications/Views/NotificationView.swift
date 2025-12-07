
import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @StateObject private var viewModel: NotificationViewModelLocal
    
    init(userId: String?) {
        _viewModel = StateObject(wrappedValue: NotificationViewModelLocal(userId: userId))
    }

    var body: some View {
        VStack(alignment: .leading) {
            headerView
            
            notificationContent
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            viewModel.setupDependencies(
                notificationVM: notificationViewModel,
                friendVM: friendViewModel,
                userVM: userViewModel
            )
            viewModel.onAppear()
        }
    }
}

// MARK: - View Components
extension NotificationView {
    
    private var headerView: some View {
        Text("Notifications")
            .modifier(NotificationHeaderModifier())
    }
    
    private var notificationContent: some View {
        ScrollView {
            if viewModel.currentUserId == nil {
                Text("Can't load notification")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                notificationsList
            }
        }
        .padding()
    }
    
    private var notificationsList: some View {
        ForEach(notificationViewModel.notifications) { notification in
            NotificationCardView(
                notification: notification,
                viewModel: viewModel
            )
        }
    }
}

// MARK: - Notification Card View
private struct NotificationCardView: View {
    let notification: NotificationContent
    let viewModel: NotificationViewModelLocal
    
    var body: some View {
        VStack(spacing: 10) {
            notificationHeader
            actionButtons
        }
        .modifier(NotificationCardModifier())
    }
    
    private var notificationHeader: some View {
        HStack {
            Text(viewModel.createAttributedString(for: notification.senderName) + " sent you a friend request")
                .lineLimit(1)
                .layoutPriority(1)
            Spacer()
            if let timestamp = notification.timestamp {
                Text(viewModel.formatTimestamp(timestamp))
                    .font(.footnote)
            }
        }
    }
    
    private var actionButtons: some View {
        HStack {
            Spacer()
            Button("Accept") {
                Task {
                    await viewModel.acceptFriendRequest(notification)
                }
            }
            .modifier(NotificationButtonModifier())
            Spacer()
            Button("Decline") {
                Task {
                    await viewModel.declineFriendRequest(notification)
                }
            }
            .modifier(NotificationButtonModifier())
            Spacer()
        }
    }
}
