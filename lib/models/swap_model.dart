enum SwapStatus { pending, accepted, rejected }

class SwapModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String requesterId;
  final String requesterEmail;
  final String ownerId;
  final String ownerEmail;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SwapModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.requesterId,
    required this.requesterEmail,
    required this.ownerId,
    required this.ownerEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SwapModel.fromMap(Map<String, dynamic> map, String id) {
    return SwapModel(
      id: id,
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterEmail: map['requesterEmail'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerEmail: map['ownerEmail'] ?? '',
      status: SwapStatus.values[map['status'] ?? 0],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'requesterId': requesterId,
      'requesterEmail': requesterEmail,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}