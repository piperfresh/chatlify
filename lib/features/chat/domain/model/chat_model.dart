import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Handle unreadCount which might be an int or missing completely
    Map<String, int> unreadCountMap = {};

    if (json['unreadCount'] is Map) {
      // If it's already a map, convert it properly
      final unreadCountData = json['unreadCount'] as Map;
      unreadCountMap = Map<String, int>.from(
          unreadCountData.map((key, value) => MapEntry(key.toString(), value as int))
      );
    }

    return ChatModel(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds']),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      lastMessageAt: json['lastMessageAt'] is Timestamp
          ? (json['lastMessageAt'] as Timestamp).toDate()
          : DateTime.parse(json['lastMessageAt']),
      lastMessageText: json['lastMessageText'],
      unreadCount: unreadCountMap,
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

  @override
  String toString() {
    return 'ChatModel{id: $id, participantIds: $participantIds, lastMessageText: $lastMessageText}';
  }
}