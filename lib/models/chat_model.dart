import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatType { direct, group, community }

class Chat {
  final String id;
  final String name;
  final String? imageUrl;
  final ChatType type;
  final List<String> memberIds;
  final String? description;
  final DateTime createdAt;
  final DateTime lastMessageTime;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final String createdBy;
  final bool isMuted;
  final bool isPublic;


  Chat({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.type,
    required this.memberIds,
    this.description,
    required this.createdAt,
    required this.lastMessageTime,
    this.lastMessage,
    this.lastMessageSenderId,
    required this.createdBy,
    required this.isMuted,
    required this.isPublic,
  });

  // --------------------------
  // Convertir a Firestore
  // --------------------------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'type': type.name,
      'memberIds': memberIds,
      'description': description,
      'createdAt': createdAt,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'createdBy': createdBy,
      'isMuted': isMuted,
      'isPublic': isPublic,
    };
  }

  // --------------------------
  // Leer desde Firestore
  // --------------------------
  factory Chat.fromMap(Map<String, dynamic> map, String docId) {
    return Chat(
      id: docId,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      type: _parseChatType(map['type']),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      description: map['description'],
      createdAt: _toDate(map['createdAt']),
      lastMessageTime: _toDate(map['lastMessageTime']),
      lastMessage: map['lastMessage'],
      lastMessageSenderId: map['lastMessageSenderId'],
      createdBy: map['createdBy'] ?? '',
      isMuted: map['isMuted'] ?? false, 
      isPublic: map['isPublic'] ?? false,
    );
  }

  // Conversión segura de fecha
  static DateTime _toDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  static ChatType _parseChatType(String? type) {
    switch (type) {
      case 'group':
        return ChatType.group;
      case 'community':
        return ChatType.community;
      case 'direct':
      default:
        return ChatType.direct;
    }
  }

  // --------------------------
  // CopyWith
  // --------------------------
  Chat copyWith({
    String? id,
    String? name,
    String? imageUrl,
    ChatType? type,
    List<String>? memberIds,
    String? description,
    DateTime? createdAt,
    DateTime? lastMessageTime,
    String? lastMessage,
    String? lastMessageSenderId,
    String? createdBy,
    bool? isMuted,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      memberIds: memberIds ?? this.memberIds,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      createdBy: createdBy ?? this.createdBy,
      isMuted: isMuted ?? this.isMuted, 
      isPublic: false,
    );
  }
}
