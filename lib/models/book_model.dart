enum BookCondition { newBook, likeNew, good, used }

class BookModel {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final String? imageUrl;
  final String ownerId;
  final String ownerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    required this.ownerId,
    required this.ownerEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String id) {
    return BookModel(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookCondition.values[map['condition'] ?? 0],
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'] ?? '',
      ownerEmail: map['ownerEmail'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition.index,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  BookModel copyWith({
    String? title,
    String? author,
    BookCondition? condition,
    String? imageUrl,
  }) {
    return BookModel(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId,
      ownerEmail: ownerEmail,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}