import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastActive;
  final String? fcmToken;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.lastActive,
    this.fcmToken,
    this.isOnline = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'fcmToken': fcmToken,
      'isOnline': isOnline,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      lastActive: json['lastActive'] != null
          ? (json['lastActive'] is Timestamp
              ? (json['lastActive'] as Timestamp).toDate()
              : DateTime.parse(json['lastActive']))
          : null,
      fcmToken: json['fcmToken'],
      isOnline: json['isOnline'] ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastActive,
    String? fcmToken,
    bool? isOnline,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      fcmToken: fcmToken ?? this.fcmToken,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, photoUrl: $photoUrl, createdAt: $createdAt, lastActive: $lastActive, fcmToken: $fcmToken, isOnline: $isOnline}';
  }
}