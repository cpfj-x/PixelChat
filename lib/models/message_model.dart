import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() {
    return {
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

  factory Message.fromMap(Map<String, dynamic> map, String docId) {
    return Message(
      id: docId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImageUrl: map['senderImageUrl'],
      content: map['content'] ?? '',
      imageUrls: map['imageUrls'] != null
          ? List<String>.from(map['imageUrls'])
          : null,
      timestamp: _toDate(map['timestamp']),
      chatId: map['chatId'] ?? '',
      isRead: map['isRead'] ?? false,
      replyToMessageId: map['replyToMessageId'],
    );
  }

  static DateTime _toDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    return DateTime.now();
  }
}
