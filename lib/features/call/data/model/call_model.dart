import 'package:chatlify/core/enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String callId;
  final String chatId;
  final String callerId;
  final String receiverId;
  final CallType callType;
  final CallStatus callStatus;
  final DateTime startTime;
  final DateTime? endTime;
  final String? channelName;
  final String? token;

  CallModel({
    required this.callId,
    required this.chatId,
    required this.callerId,
    required this.receiverId,
    required this.callType,
    required this.callStatus,
    required this.startTime,
    this.endTime,
    this.channelName,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'callId': callId,
      'callerId': callerId,
      'receiverId': receiverId,
      'callType': callType.name,
      'callStatus': callStatus.name,
      'startTime': startTime,
      'endTime': endTime,
      'channelName': channelName,
      'token': token,
      'chatId': chatId,
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    print("Parsing call model: ${json['callId']}");

    // Helper function to safely parse DateTime from various formats
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          print("Error parsing date string: $value");
          return null;
        }
      }
      print("Unknown date format: $value (${value.runtimeType})");
      return null;
    }

    try {
      final callType = CallType.values.byName(json['callType'] ?? 'voice');
      final callStatus = CallStatus.values.byName(json['callStatus'] ?? 'pending');
      final startTime = parseDateTime(json['startTime']) ?? DateTime.now();
      final endTime = parseDateTime(json['endTime']);

      return CallModel(
        callId: json['callId'] ?? '',
        chatId: json['chatId'] ?? '',
        callerId: json['callerId'] ?? '',
        receiverId: json['receiverId'] ?? '',
        callType: callType,
        callStatus: callStatus,
        startTime: startTime,
        endTime: endTime,
        channelName: json['channelName'],
        token: json['token'],
      );
    } catch (e) {
      print("Error creating CallModel from JSON: $e");
      rethrow;
    }
  }

  // factory CallModel.fromJson(Map<String, dynamic> json) {
  //   return CallModel(
  //     callId: json['callId'],
  //     chatId: json['chatId'],
  //     callerId: json['callerId'],
  //     receiverId: json['receiverId'],
  //     startTime: DateTime.parse(json['startTime']),
  //     endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
  //     callType: CallType.values.byName(json['callType']),
  //     callStatus: CallStatus.values.byName(json['callStatus']),
  //     channelName: json['channelName'],
  //     token: json['token'],
  //   );
  // }

  @override
  String toString() {
    return 'CallModel{callId: $callId, chatId: $chatId, callerId: $callerId, receiverId: $receiverId, callType: $callType, callStatus: $callStatus, startTime: $startTime, endTime: $endTime, channelName: $channelName, token: $token}';
  }
}
