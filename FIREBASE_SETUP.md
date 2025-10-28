# Firebase Setup Guide for BookSwap App

## Prerequisites

1. Flutter SDK installed
2. Firebase CLI installed (`npm install -g firebase-tools`)
3. FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)

## Step-by-Step Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `bookswap-app`
4. Enable Google Analytics (optional)
5. Create project

### 2. Enable Firebase Services

#### Authentication
1. Go to Authentication → Sign-in method
2. Enable "Email/Password" provider
3. Save changes

#### Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Create database

#### Storage
1. Go to Storage
2. Click "Get started"
3. Choose "Start in test mode"
4. Select same location as Firestore
5. Done

### 3. Configure Flutter App

#### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Configure Firebase for Flutter
```bash
cd bookswap_app
firebase login
flutterfire configure
```

This will:
- Create `firebase_options.dart` with your project configuration
- Add necessary configuration files for each platform

### 4. Platform-Specific Configuration

#### Android
1. Minimum SDK version is already set to 21 in `android/app/build.gradle`
2. Internet permission is already added in `AndroidManifest.xml`

#### iOS
1. Minimum iOS version is set to 11.0 in `ios/Podfile`
2. Camera and photo library permissions need to be added to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos of books</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select book images</string>
```

### 5. Firestore Security Rules

Replace the default rules in Firestore with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read books, only owners can write
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || request.auth.uid == resource.data.ownerId);
    }
    
    // Users can read swaps they're involved in, create new swaps
    match /swaps/{swapId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.requesterId || 
         request.auth.uid == resource.data.ownerId);
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.requesterId;
      allow update: if request.auth != null && 
        request.auth.uid == resource.data.ownerId;
    }
    
    // Chat rooms and messages for participants only
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
  }
}
```

### 6. Storage Security Rules

Replace the default Storage rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_images/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.uid != null;
    }
  }
}
```

### 7. Test the Setup

1. Run the app: `flutter run`
2. Try signing up with a new account
3. Check Firebase Console to see if user was created
4. Try adding a book and check Firestore for the document
5. Test image upload by adding a book with a photo

## Common Issues and Solutions

### Issue: "Default FirebaseApp is not initialized"
**Solution**: Make sure `Firebase.initializeApp()` is called in `main()` before `runApp()`

### Issue: "Permission denied" errors
**Solution**: Check Firestore security rules and ensure user is authenticated

### Issue: Image upload fails
**Solution**: Check Storage security rules and internet connectivity

### Issue: Email verification not working
**Solution**: Check spam folder and ensure Firebase Auth is properly configured

## Environment Variables (Optional)

For production apps, consider using environment variables for sensitive configuration:

1. Create `.env` file (already in .gitignore)
2. Add Firebase configuration
3. Use `flutter_dotenv` package to load variables

## Monitoring and Analytics

1. Enable Crashlytics for crash reporting
2. Set up Performance Monitoring
3. Configure Analytics events for user actions

## Backup Strategy

1. Enable Firestore automatic backups
2. Export user data regularly
3. Test restore procedures

This setup provides a complete Firebase backend for the BookSwap application with proper security and scalability considerations.