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
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'memberIds': memberIds,
      'description': description,
      'createdAt': createdAt,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'createdBy': createdBy,
      'isMuted': isMuted,
    };
  }

  // Crear desde Firestore
  factory Chat.fromMap(Map<String, dynamic> map, String docId) {
    return Chat(
      id: docId,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      type: _parseChatType(map['type']),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      description: map['description'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      lastMessageTime: map['lastMessageTime']?.toDate() ?? DateTime.now(),
      lastMessage: map['lastMessage'],
      lastMessageSenderId: map['lastMessageSenderId'],
      createdBy: map['createdBy'] ?? '',
      isMuted: map['isMuted'] ?? false,
    );
  }

  // Copiar con cambios
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
    );
  }

  static ChatType _parseChatType(String? type) {
    switch (type) {
      case 'group':
        return ChatType.group;
      case 'community':
        return ChatType.community;
      default:
        return ChatType.direct;
    }
  }
}
