import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  final List<String>? imageUrls;

  final String? videoUrl;
  final String? videoThumbnail;

  final String? audioUrl;

  final String? replyToMessageId;
  final String? replyToMessageContent;

  final bool isRead;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.imageUrls,
    this.videoUrl,
    this.videoThumbnail,
    this.audioUrl,
    this.replyToMessageId,
    this.replyToMessageContent,
    this.isRead = false,
  });

  factory Message.fromMap(Map<String, dynamic> data, String docId) {
    return Message(
      id: docId,
      chatId: data['chatId'],
      senderId: data['senderId'],
      senderName: data['senderName'],
      content: data['content'] ?? "",
      timestamp: (data['timestamp'] as Timestamp).toDate(),

      imageUrls: data['imageUrls'] != null
          ? List<String>.from(data['imageUrls'])
          : null,

      videoUrl: data['videoUrl'],
      videoThumbnail: data['videoThumbnail'],

      audioUrl: data['audioUrl'],

      replyToMessageId: data['replyToMessageId'],
      replyToMessageContent: data['replyToMessageContent'],

      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'videoThumbnail': videoThumbnail,
      'audioUrl': audioUrl,
      'replyToMessageId': replyToMessageId,
      'replyToMessageContent': replyToMessageContent,
      'isRead': isRead,
    };
  }
}
