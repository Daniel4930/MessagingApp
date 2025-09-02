# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import firestore_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore, messaging

# For cost control, you can set the maximum number of containers that can be
# running at the same time. This helps mitigate the impact of unexpected
# traffic spikes by instead downgrading performance. This limit is a per-function
# limit. You can override the limit for each function using the max_instances
# parameter in the decorator, e.g. @https_fn.on_request(max_instances=5).
set_global_options(max_instances=10)

initialize_app()

@firestore_fn.on_document_created(document="channels/{channelId}/messages/{messageId}", database="messaging-app")
def send_message_notification(event: firestore_fn.Event[firestore_fn.Change]) -> None:
    """
    Sends a push notification to users in a channel when a new message is created.
    """
    db = firestore.client(database_id="messaging-app")

    channel_id = event.params["channelId"]
    message_data = event.data.to_dict()
    sender_id = message_data.get("senderId")
    message_text = message_data.get("text")

    if not sender_id:
        print("Message data is missing senderId.")
        return
    
    # If message_text is None or empty, use a default message.
    notification_body = message_text if message_text else "Sent an attachment"

    # Get the channel to find the members
    channel_ref = db.collection("channels").document(channel_id)
    channel_snapshot = channel_ref.get()
    if not channel_snapshot.exists:
        print(f"Channel {channel_id} not found.")
        return

    channel_data = channel_snapshot.to_dict()
    member_ids = channel_data.get("memberIds", [])

    # Get the sender's user data to get their display name
    sender_ref = db.collection("users").document(sender_id)
    sender_snapshot = sender_ref.get()
    if not sender_snapshot.exists:
        print(f"Sender {sender_id} not found.")
        return
    
    sender_data = sender_snapshot.to_dict()

    sender_displayName = sender_data.get("displayName", "").strip()
    sender_userName = sender_data.get("userName", "")
    sender_name = sender_displayName if sender_displayName else sender_userName

    # Get the recipients' FCM tokens
    recipient_ids = [uid for uid in member_ids if uid != sender_id]
    
    if not recipient_ids:
        print("No recipients to send notifications to.")
        return

    users_ref = db.collection("users")
    for recipient_id in recipient_ids:
        user_snapshot = users_ref.document(recipient_id).get()
        if user_snapshot.exists:
            user_data = user_snapshot.to_dict()
            fcm_token = user_data.get("fcmToken")

            if fcm_token:
                # Send notification
                notification = messaging.Notification(
                    title=f"New message from {sender_name}",
                    body=notification_body,
                )
                message = messaging.Message(
                    notification=notification,
                    token=fcm_token,
                    apns=messaging.APNSConfig(
                        payload=messaging.APNSPayload(
                            aps=messaging.Aps(sound="default"),
                        ),
                    ),
                )
                try:
                    messaging.send(message)
                    print(f"Notification sent to {recipient_id}")
                except Exception as e:
                    print(f"Error sending notification to {recipient_id}: {e}")
