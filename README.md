# BookSwap App

A Flutter mobile application for students to exchange textbooks through a marketplace system with real-time chat functionality.

## Features

- **Authentication**: Firebase Auth with email verification
- **Book Management**: Full CRUD operations for book listings
- **Swap System**: Real-time swap offers with status tracking
- **Chat System**: Real-time messaging between users
- **State Management**: Provider pattern for reactive UI
- **Image Upload**: Firebase Storage for book cover images

## Architecture

```
lib/
├── models/          # Data models
├── services/        # Firebase services
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── utils/          # Constants and utilities
```

## Setup Instructions

### 1. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication with Email/Password
3. Create Firestore Database
4. Enable Firebase Storage
5. Install Firebase CLI: `npm install -g firebase-tools`
6. Run `firebase login` and `firebase init`
7. Run `flutterfire configure` to generate firebase_options.dart

### 2. Dependencies

Run the following command to install dependencies:

```bash
flutter pub get
```

### 3. Platform Configuration

#### Android
- Minimum SDK: 21
- Add internet permission in `android/app/src/main/AndroidManifest.xml`

#### iOS
- Minimum iOS version: 11.0
- Add camera and photo library permissions in `ios/Runner/Info.plist`

### 4. Running the App

```bash
flutter run
```

## Database Schema

### Users Collection
```
users/{userId}
├── uid: string
├── email: string
├── displayName: string
├── emailVerified: boolean
└── createdAt: timestamp
```

### Books Collection
```
books/{bookId}
├── title: string
├── author: string
├── condition: number (0-3)
├── imageUrl: string
├── ownerId: string
├── ownerEmail: string
├── createdAt: timestamp
└── updatedAt: timestamp
```

### Swaps Collection
```
swaps/{swapId}
├── bookId: string
├── bookTitle: string
├── requesterId: string
├── requesterEmail: string
├── ownerId: string
├── ownerEmail: string
├── status: number (0-2)
├── createdAt: timestamp
└── updatedAt: timestamp
```

### Chats Collection
```
chats/{chatId}
├── participants: array
├── swapId: string
├── createdAt: timestamp
├── lastMessageAt: timestamp
└── messages/{messageId}
    ├── senderId: string
    ├── senderEmail: string
    ├── message: string
    └── timestamp: timestamp
```

## State Management

The app uses Provider pattern for state management:

- **AuthProvider**: Manages authentication state
- **BookProvider**: Handles book CRUD operations
- **SwapProvider**: Manages swap offers and status
- **ChatProvider**: Handles chat functionality

## Key Features Implementation

### Authentication Flow
1. User signs up with email/password
2. Email verification sent automatically
3. User must verify email before signing in
4. Real-time auth state changes

### Book Management
1. Create: Add new book with image upload
2. Read: Browse all listings or user's books
3. Update: Edit book details and image
4. Delete: Remove book and associated image

### Swap System
1. Users can send swap offers for books
2. Real-time status updates (Pending/Accepted/Rejected)
3. Automatic chat room creation on swap initiation
4. Prevention of duplicate swap offers

### Chat System
1. Real-time messaging using Firestore
2. Chat rooms linked to swap offers
3. Message history persistence
4. User-friendly chat interface

## Error Handling

The app includes comprehensive error handling for:
- Network connectivity issues
- Firebase authentication errors
- Firestore operation failures
- Image upload problems
- Form validation errors

## Testing

Run tests with:
```bash
flutter test
```

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is for educational purposes as part of a mobile development course.