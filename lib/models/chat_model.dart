import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatType { direct, group, community }

class Chat {
  final String id;
  final String name;
  final String? imageUrl;
  final ChatType type;
  final List<String> memberIds;
  final List<String> adminIds; // <--- AÑADIDO
  final String? description;
  final DateTime createdAt;
  final DateTime lastMessageTime;
  final String createdBy;
  final bool isMuted;
  final String? lastMessage;
  final String? lastMessageSenderId;

  Chat({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.type,
    required this.memberIds,
    required this.adminIds, // <--- AÑADIDO
    this.description,
    required this.createdAt,
    required this.lastMessageTime,
    required this.createdBy,
    required this.isMuted,
    this.lastMessage,
    this.lastMessageSenderId, required bool isPublic,
  });

  // ----------------------------------------------------------------------------
  // FROM MAP
  // ----------------------------------------------------------------------------
  factory Chat.fromMap(Map<String, dynamic> map, String id) {
    return Chat(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      type: _parseType(map['type']),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      adminIds: List<String>.from(map['adminIds'] ?? []), // <--- AÑADIDO
      description: map['description'],
      createdAt: _toDate(map['createdAt']),
      lastMessageTime: _toDate(map['lastMessageTime']),
      createdBy: map['createdBy'] ?? '',
      isMuted: map['isMuted'] ?? false,
      lastMessage: map['lastMessage'],
      lastMessageSenderId: map['lastMessageSenderId'], 
      isPublic: false,
    );
  }

  // ----------------------------------------------------------------------------
  // TO MAP
  // ----------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'type': type.name,
      'memberIds': memberIds,
      'adminIds': adminIds, // <--- AÑADIDO
      'description': description,
      'createdAt': createdAt,
      'lastMessageTime': lastMessageTime,
      'createdBy': createdBy,
      'isMuted': isMuted,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
    };
  }

  // ----------------------------------------------------------------------------
  // COPY WITH
  // ----------------------------------------------------------------------------
  Chat copyWith({
    String? name,
    String? imageUrl,
    List<String>? memberIds,
    List<String>? adminIds,
    String? description,
  }) {
    return Chat(
      id: id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds, // <--- AÑADIDO
      description: description ?? this.description,
      createdAt: createdAt,
      lastMessageTime: lastMessageTime,
      createdBy: createdBy,
      isMuted: isMuted,
      lastMessage: lastMessage,
      lastMessageSenderId: lastMessageSenderId, 
      isPublic: false,
    );
  }

  // ----------------------------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------------------------
  static ChatType _parseType(String? type) {
    switch (type) {
      case 'direct':
        return ChatType.direct;
      case 'group':
        return ChatType.group;
      case 'community':
        return ChatType.community;
      default:
        return ChatType.direct;
    }
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
