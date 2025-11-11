# BookSwap App - Design Summary

## 1. Database Schema (Firestore Collections)

### 1.1 Users Collection
```
users/{userId}
├── uid: string
├── email: string
├── displayName: string
├── emailVerified: boolean
└── createdAt: timestamp
```

**Purpose**: Stores user profile information synced from Firebase Authentication.

**Key Design Decision**: User documents are created automatically upon signup and updated when email verification status changes. The `uid` field matches Firebase Auth UID for easy cross-referencing.

---

### 1.2 Books Collection
```
books/{bookId}
├── title: string
├── author: string
├── condition: number (0=New, 1=Like New, 2=Good, 3=Used)
├── imageUrl: string (Firebase Storage URL)
├── ownerId: string (references users/{userId})
├── ownerEmail: string
├── createdAt: timestamp
└── updatedAt: timestamp
```

**Purpose**: Stores all book listings in the marketplace.

**Key Design Decisions**:
- `condition` stored as integer enum for efficient querying and sorting
- `ownerEmail` denormalized for quick display without additional user lookup
- `imageUrl` points to Firebase Storage for scalable image hosting
- Composite index on `ownerId + createdAt` enables efficient "My Listings" queries

---

### 1.3 Swaps Collection
```
swaps/{swapId}
├── bookId: string (references books/{bookId})
├── bookTitle: string
├── requesterId: string (user who initiated swap)
├── requesterEmail: string
├── ownerId: string (book owner)
├── ownerEmail: string
├── status: number (0=Pending, 1=Accepted, 2=Rejected)
├── createdAt: timestamp
└── updatedAt: timestamp
```

**Purpose**: Tracks swap offers between users.

**Key Design Decisions**:
- Denormalized `bookTitle`, `requesterEmail`, and `ownerEmail` to avoid N+1 queries
- Status as integer enum for efficient filtering (e.g., show only pending swaps)
- Composite indexes:
  - `requesterId + createdAt` for "Sent Swaps" view
  - `ownerId + createdAt` for "Received Swaps" view
  - `bookId + requesterId + status` for duplicate swap prevention

---

### 1.4 Chats Collection
```
chats/{chatId}
├── participants: array<string> (array of user IDs)
├── swapId: string (references swaps/{swapId})
├── bookTitle: string
├── requesterId: string
├── requesterEmail: string
├── ownerId: string
├── ownerEmail: string
├── status: number (synced from swap status)
├── createdAt: timestamp
├── lastMessageAt: timestamp
└── messages/{messageId}
    ├── senderId: string
    ├── senderEmail: string
    ├── message: string
    └── timestamp: timestamp
```

**Purpose**: Enables real-time chat between users after swap initiation.

**Key Design Decisions**:
- **Performance Optimization**: Swap details (bookTitle, emails, status) are cached in the chat document to eliminate N+1 queries when loading chat list
- `participants` array enables efficient querying: "show all chats where I'm a participant"
- Composite index: `participants (array-contains) + lastMessageAt (descending)` for sorted chat list
- Messages stored as subcollection for scalability (doesn't load all messages when fetching chat list)
- `status` field synced from swaps collection when swap status changes

---

## 2. Swap State Modeling

### 2.1 State Flow
```
Book Listed → Swap Requested → Pending → Accepted/Rejected
```

### 2.2 State Transitions
1. **Book Listed**: Book exists in `books` collection, no swap document
2. **Swap Requested**: 
   - New document created in `swaps` collection with `status: 0` (Pending)
   - Chat room automatically created in `chats` collection
   - Duplicate prevention: Query checks if pending swap already exists for same book + requester
3. **Accepted**: Owner updates swap `status: 1`, chat room status synced
4. **Rejected**: Owner updates swap `status: 2`, chat room status synced

### 2.3 Real-Time Synchronization
- **Firestore Streams**: All collections use `.snapshots()` for real-time updates
- **Automatic UI Updates**: When swap status changes, both users see updates instantly via Provider state management
- **Chat Status Sync**: When swap status updates, corresponding chat document is also updated to reflect badge color in chat list

---

## 3. State Management Implementation

### 3.1 Architecture: Provider Pattern

**Why Provider?**
- Built-in Flutter solution, no external dependencies
- Simple reactive model using `ChangeNotifier`
- Efficient widget rebuilds with `Consumer` widgets
- Easy to test and maintain

### 3.2 Provider Structure

```
lib/providers/
├── auth_provider.dart      → Manages authentication state
├── book_provider.dart      → Handles book CRUD operations
├── swap_provider.dart      → Manages swap offers
└── chat_provider.dart      → Controls chat functionality
```

### 3.3 State Flow Example (Creating a Swap)

```dart
// 1. User taps "Swap" button in UI
BrowseScreen → calls Provider

// 2. Provider updates loading state
SwapProvider.createSwapOffer() {
  _isLoading = true;
  notifyListeners(); // UI shows loading spinner
}

// 3. Service writes to Firestore
SwapService.createSwapOffer() → Firestore

// 4. Firestore stream detects change
SwapService.getUserSwaps().listen() → emits new list

// 5. Provider updates state
SwapProvider receives new list
_userSwaps = newSwaps;
notifyListeners(); // UI rebuilds with new data

// 6. UI automatically updates
Consumer<SwapProvider> rebuilds → shows new swap
```

### 3.4 Key Provider Methods

**AuthProvider**:
- `signUp()`, `signIn()`, `signOut()` - Authentication actions
- `authStateChanges` stream - Listens to Firebase Auth state
- Auto-creates user document in Firestore on signup

**BookProvider**:
- `listenToAllBooks()` - Real-time stream of all books (Browse screen)
- `listenToUserBooks()` - Real-time stream of user's books (My Listings)
- `createBook()`, `updateBook()`, `deleteBook()` - CRUD operations

**SwapProvider**:
- `listenToUserSwaps()` - Swaps sent by current user
- `listenToReceivedSwaps()` - Swaps received by current user
- `createSwapOffer()` - Initiates swap with duplicate prevention
- `updateSwapStatus()` - Accept/reject swap, syncs to chat

**ChatProvider**:
- `listenToUserChatRooms()` - Real-time chat list with cached swap data
- `listenToChatMessages()` - Messages for specific chat
- `sendMessage()` - Sends message and updates `lastMessageAt`

---

## 4. Design Trade-offs and Challenges

### 4.1 Data Denormalization
**Trade-off**: Stored redundant data (emails, bookTitle) in multiple collections

**Pros**:
- Eliminated N+1 query problem (was causing 4+ second chat load times)
- Single query loads all necessary data for UI
- Reduced Firestore read costs

**Cons**:
- Data can become inconsistent if user changes email
- Increased storage usage
- Must update multiple documents when data changes

**Resolution**: Accepted trade-off because read performance is critical for UX, and email changes are rare.

---

### 4.2 Firebase API Key Exposure
**Challenge**: Accidentally committed `firebase_options.dart` with API keys to GitHub

**Resolution**:
1. Removed file from Git history
2. Added to `.gitignore`
3. Regenerated all Firebase API keys in console
4. Updated security rules to restrict unauthorized access

**Lesson**: Always add sensitive files to `.gitignore` before first commit.

---

### 4.3 Firestore Composite Indexes
**Challenge**: Complex queries required multiple composite indexes that weren't auto-created

**Errors Encountered**:
```
[cloud_firestore/failed-precondition] The query requires an index
```

**Resolution**: Created 6 composite indexes:
- `books`: `ownerId (Asc) + createdAt (Desc)`
- `swaps`: `requesterId (Asc) + createdAt (Desc)`
- `swaps`: `ownerId (Asc) + createdAt (Desc)`
- `swaps`: `bookId (Asc) + requesterId (Asc) + status (Asc)`
- `chats`: `participants (Array-contains) + lastMessageAt (Desc)`

**Lesson**: Firebase provides index creation links in error messages - follow them immediately.

---

### 4.4 Image Upload Web Compatibility
**Challenge**: `Image.file()` doesn't work on Flutter web (blob URLs vs file paths)

**Error**:
```
Unsupported operation: Platform._operatingSystem
```

**Resolution**: 
- Used `XFile` from `image_picker` instead of `File`
- Conditional rendering: `Image.network()` for web, `Image.file()` for mobile
- Used `putData()` for web uploads, `putFile()` for mobile

---

### 4.5 Chat Performance Optimization
**Challenge**: Chat list took 4+ seconds to load due to N+1 queries (1 query for chats + N queries for swap details)

**Original Implementation**:
```dart
// Bad: Separate query for each chat
ListView.builder(
  itemBuilder: (context, index) {
    return FutureBuilder<SwapModel?>(
      future: getSwap(chatRoom.swapId), // N queries!
      ...
    );
  }
)
```

**Optimized Implementation**:
```dart
// Good: All data in one query
ChatRoom {
  swapId, bookTitle, requesterEmail, ownerEmail, status // Cached!
}
```

**Result**: Chat list now loads instantly (< 100ms)

---

### 4.6 Email Verification Sync
**Challenge**: Email verification status in Firestore wasn't updating after user verified email

**Resolution**: Added `user.reload()` in sign-in flow to fetch latest verification status from Firebase Auth before syncing to Firestore

---

### 4.7 Navigation Stack Issues
**Challenge**: After sign-in, pressing back button returned to sign-in screen

**Resolution**: Added `Navigator.pop(context)` after successful authentication to remove sign-in screen from stack

---

## 5. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Browse   │  │   My     │  │  Chats   │  │ Settings │   │
│  │ Screen   │  │ Listings │  │  Screen  │  │  Screen  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┴─────────────┴─────────────┘
                      │
        ┌─────────────▼─────────────────────────────────────┐
        │         State Management (Provider)               │
        │  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
        │  │   Auth   │  │   Book   │  │   Swap   │       │
        │  │ Provider │  │ Provider │  │ Provider │       │
        │  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
        └───────┼─────────────┼─────────────┼──────────────┘
                │             │             │
        ┌───────▼─────────────▼─────────────▼──────────────┐
        │              Services Layer                       │
        │  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
        │  │   Auth   │  │   Book   │  │   Swap   │       │
        │  │ Service  │  │ Service  │  │ Service  │       │
        │  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
        └───────┼─────────────┼─────────────┼──────────────┘
                │             │             │
        ┌───────▼─────────────▼─────────────▼──────────────┐
        │                Firebase Backend                   │
        │  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
        │  │   Auth   │  │ Firestore│  │ Storage  │       │
        │  └──────────┘  └──────────┘  └──────────┘       │
        └──────────────────────────────────────────────────┘
```

---

## 6. Security Considerations

### 6.1 Firestore Security Rules
```javascript
// Users can only read/write their own data
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Anyone can read books, only owner can update/delete
match /books/{bookId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update, delete: if request.auth.uid == resource.data.ownerId;
}
```

### 6.2 Storage Security Rules
```javascript
// Anyone can read images, authenticated users can upload
match /book_images/{imageId} {
  allow read: if true;
  allow write: if request.auth != null;
}
```

---

## 7. Performance Metrics

- **Chat List Load Time**: < 100ms (after optimization)
- **Book Feed Load Time**: ~200ms for 50 books
- **Image Upload Time**: 1-3 seconds depending on size
- **Real-time Update Latency**: < 500ms (Firestore sync)
- **Dart Analyzer Warnings**: 0

---

## 8. Future Improvements

1. **Pagination**: Implement lazy loading for large book lists
2. **Search**: Add full-text search for books using Algolia
3. **Push Notifications**: Notify users of new swap offers
4. **Image Compression**: Reduce storage costs by compressing images before upload
5. **Offline Support**: Cache data locally for offline viewing
6. **User Ratings**: Add rating system for successful swaps
