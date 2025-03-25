import 'package:chatlify/core/enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, bool> readStatus;

  MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
    Map<String, bool>? readStatus,
  }) : readStatus = readStatus ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'readStatus': readStatus,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Convert readStatus from dynamic to Map<String, bool>
    Map<String, bool> readStatusMap = {};
    if (json['readStatus'] is Map) {
      final readStatusData = json['readStatus'] as Map;
      readStatusMap = Map<String, bool>.from(readStatusData
          .map((key, value) => MapEntry(key.toString(), value as bool)));
    }
    return MessageModel(
      messageId: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      content: json['content'],
      type: json['type'] == 'image' ? MessageType.image : MessageType.text,
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      readStatus: readStatusMap,
    );
  }
}
