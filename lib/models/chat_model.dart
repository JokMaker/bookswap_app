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
  final DateTime createdAt;
  final DateTime lastMessageAt;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.swapId,
    required this.createdAt,
    required this.lastMessageAt,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      swapId: map['swapId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(map['lastMessageAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'swapId': swapId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessageAt': lastMessageAt.millisecondsSinceEpoch,
    };
  }
}