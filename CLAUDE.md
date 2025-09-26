# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI messaging application built for iOS with Firebase backend integration. The app features real-time messaging, user authentication, file sharing, and push notifications.

### Key Dependencies
- **Firebase SDK**: Core, Auth, Firestore, Storage, Messaging, Functions, Crashlytics, Analytics
- **Kingfisher**: Image loading and caching
- **Target iOS Version**: 18.0+

## Build and Development Commands

### Building the App
```bash
# Build from Xcode
# Open MessagingApp.xcodeproj in Xcode
# Press Cmd+B to build
# Press Cmd+R to run on simulator/device

# Build from command line (if xcodebuild available)
xcodebuild -project MessagingApp.xcodeproj -scheme MessagingApp -configuration Debug build
```

### Testing
```bash
# Run unit tests
xcodebuild test -project MessagingApp.xcodeproj -scheme MessagingApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -project MessagingApp.xcodeproj -scheme MessagingApp -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing MessagingAppUITests
```

### Firebase Functions Development
```bash
# Navigate to functions directory
cd functions

# Install dependencies
pip install -r requirements.txt

# Deploy functions (requires Firebase CLI)
firebase deploy --only functions
```

## Architecture Overview

### Core Structure
- **App Entry Point**: `MessagingAppApp.swift` - Configures Firebase, handles app lifecycle and dependency injection
- **Models**: Located in `Model/` - Core data structures (User, Channel, Message, etc.)
- **Views**: Located in `View/` - SwiftUI views organized by feature
- **ViewModels**: Located in `View Model/` - MVVM architecture with ObservableObject classes
- **Services**: Located in `Services/` - Firebase integration and business logic
- **Reusable Components**: Located in `Resuable/` - Shared UI components

### Key Models
- **User**: User profiles with authentication, online status, friends list
- **Channel**: Direct message channels between users
- **Message**: Text messages with file attachments and metadata
- **OnlineStatus**: Enum for user availability (online, idle, doNotDisturb, offline, invisible)

### State Management
The app uses SwiftUI's `@StateObject` and `@EnvironmentObject` for state management:
- `UserViewModel`: Current user state and authentication
- `FriendViewModel`: Friends list and friend requests
- `MessageViewModel`: Message history and real-time updates
- `ChannelViewModel`: Channel management and navigation
- `NotificationViewModel`: Push notification handling

### Firebase Integration
- **Authentication**: Email/password auth via `FirebaseAuthService`
- **Database**: Firestore for user data, channels, and messages via `FirebaseCloudStoreService`
- **Storage**: File uploads via `FirebaseStorageService`
- **Functions**: Push notification triggers in `functions/main.py`
- **Crashlytics**: Crash reporting with build script integration

### Key Features
- Real-time messaging with Firebase Firestore listeners
- File sharing (photos, videos, documents) with Firebase Storage
- Push notifications via Firebase Cloud Messaging
- Photo library integration with permission handling
- User presence and online status
- Friend system with requests
- Message editing and embedded link previews

### Development Notes
- Uses iOS 18.0+ APIs and SwiftUI lifecycle
- Firebase Crashlytics run script is configured in build phases
- App supports portrait orientation only on iPhone
- Uses dark theme (`UIUserInterfaceStyle = Dark`)
- File uploads use UUID-based naming for uniqueness
- Message attachments support photos, videos, and documents