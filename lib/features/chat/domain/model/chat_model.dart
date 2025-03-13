class ChatModel {
  final String id;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String? lastMessageText;
  final Map<String, int> unreadCount;

  ChatModel({
    required this.id,
    required this.participantIds,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessageText,
    required this.unreadCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'lastMessageText': lastMessageText,
      'unreadCount': unreadCount,
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds']),
      createdAt: DateTime.parse(json['createdAt']),
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      lastMessageText: json['lastMessageText'],
      unreadCount: Map<String, int>.from(json['unreadCount'] ?? {}),
    );
  }

  ChatModel copyWith({
    String? id,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessageText,
    Map<String, int>? unreadCount,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
