class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String content;
  final List<String>? imageUrls;
  final DateTime timestamp;
  final String chatId;
  final bool isRead;
  final String? replyToMessageId;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.content,
    this.imageUrls,
    required this.timestamp,
    required this.chatId,
    required this.isRead,
    this.replyToMessageId,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'content': content,
      'imageUrls': imageUrls,
      'timestamp': timestamp,
      'chatId': chatId,
      'isRead': isRead,
      'replyToMessageId': replyToMessageId,
    };
  }

  // Crear desde Firestore
  factory Message.fromMap(Map<String, dynamic> map, String docId) {
    return Message(
      id: docId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImageUrl: map['senderImageUrl'],
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      chatId: map['chatId'] ?? '',
      isRead: map['isRead'] ?? false,
      replyToMessageId: map['replyToMessageId'],
    );
  }

  // Copiar con cambios
  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderImageUrl,
    String? content,
    List<String>? imageUrls,
    DateTime? timestamp,
    String? chatId,
    bool? isRead,
    String? replyToMessageId,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      timestamp: timestamp ?? this.timestamp,
      chatId: chatId ?? this.chatId,
      isRead: isRead ?? this.isRead,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }
}
