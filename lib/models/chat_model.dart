class ChatMessage {
  final String id;
  final String senderId;
  final String senderEmail;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

class ChatRoom {
  final String id;
  final List<String> participants;
  final String swapId;
  final String bookTitle;
  final String requesterId;
  final String requesterEmail;
  final String ownerId;
  final String ownerEmail;
  final int status;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String? lastMessage;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.swapId,
    required this.bookTitle,
    required this.requesterId,
    required this.requesterEmail,
    required this.ownerId,
    required this.ownerEmail,
    required this.status,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessage,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      swapId: map['swapId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterEmail: map['requesterEmail'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerEmail: map['ownerEmail'] ?? '',
      status: map['status'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(map['lastMessageAt'] ?? 0),
      lastMessage: map['lastMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'swapId': swapId,
      'bookTitle': bookTitle,
      'requesterId': requesterId,
      'requesterEmail': requesterEmail,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessageAt': lastMessageAt.millisecondsSinceEpoch,
      if (lastMessage != null) 'lastMessage': lastMessage,
    };
  }
}