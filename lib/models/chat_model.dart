class ChatParticipant {
  final int id;
  final String displayName;
  final String? profilePictureUrl;

  ChatParticipant({
    required this.id,
    required this.displayName,
    this.profilePictureUrl,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'],
      displayName: json['display_name'] ?? 'Unknown User',
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

class Message {
  final int id;
  final int chatId;
  final int senderId;
  final String content;
  final String messageType;
  final DateTime sentAt;
  final bool isRead;
  final String? senderName;
  final String? senderProfilePicture;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.sentAt,
    required this.isRead,
    this.senderName,
    this.senderProfilePicture,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'],
      messageType: json['message_type'] ?? 'text',
      sentAt: DateTime.parse(json['sent_at']),
      isRead: json['is_read'] ?? false,
      senderName: json['sender_name'],
      senderProfilePicture: json['sender_profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
      'sender_name': senderName,
      'sender_profile_picture': senderProfilePicture,
    };
  }

  Message copyWith({
    int? id,
    int? chatId,
    int? senderId,
    String? content,
    String? messageType,
    DateTime? sentAt,
    bool? isRead,
    String? senderName,
    String? senderProfilePicture,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      senderName: senderName ?? this.senderName,
      senderProfilePicture: senderProfilePicture ?? this.senderProfilePicture,
    );
  }
}

class Chat {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int? dinnerId;
  final ChatParticipant otherUser;
  final Message? lastMessage;
  final int unreadCount;

  Chat({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.dinnerId,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
      dinnerId: json['dinner_id'],
      otherUser: ChatParticipant.fromJson(json['other_user']),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'dinner_id': dinnerId,
      'other_user': otherUser.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
    };
  }
}

class ChatDetail extends Chat {
  final List<Message> messages;

  ChatDetail({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
    int? dinnerId,
    required ChatParticipant otherUser,
    Message? lastMessage,
    int unreadCount = 0,
    this.messages = const [],
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
          dinnerId: dinnerId,
          otherUser: otherUser,
          lastMessage: lastMessage,
          unreadCount: unreadCount,
        );

  factory ChatDetail.fromJson(Map<String, dynamic> json) {
    return ChatDetail(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
      dinnerId: json['dinner_id'],
      otherUser: ChatParticipant.fromJson(json['other_user']),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((msg) => Message.fromJson(msg))
              .toList()
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['messages'] = messages.map((msg) => msg.toJson()).toList();
    return json;
  }
}

// WebSocket message types
class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;

  WebSocketMessage({
    required this.type,
    required this.data,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'],
      data: json['data'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
    };
  }
}

class ChatCreateRequest {
  final int otherUserId;
  final int? dinnerId;

  ChatCreateRequest({
    required this.otherUserId,
    this.dinnerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'other_user_id': otherUserId,
      'dinner_id': dinnerId,
    };
  }
}
