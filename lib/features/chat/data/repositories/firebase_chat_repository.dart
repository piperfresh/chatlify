import 'dart:io';

import 'package:chatlify/core/app_constants.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/chat/domain/model/chat_model.dart';
import 'package:chatlify/features/chat/domain/model/message_model.dart';
import 'package:chatlify/features/chat/domain/repositories/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final firebaseChatRepositoryProvider = Provider(
  (ref) {
    return FirebaseChatRepository(
        FirebaseFirestore.instance, FirebaseStorage.instance, const Uuid());
  },
);

class FirebaseChatRepository implements ChatRepository {
  FirebaseChatRepository(this._fireStore, this._firebaseStorage, this._uuid);

  final FirebaseFirestore _fireStore;
  final FirebaseStorage _firebaseStorage;
  final Uuid _uuid;

  @override
  Stream<UserModel?> getUserStream(String userId) {
    return _fireStore
        .collection(AppConstants.users)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  @override
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _fireStore
        .collection(AppConstants.chats)
        .where(AppConstants.participantIds, arrayContains: userId)
        .orderBy(AppConstants.lastMessageAt, descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return ChatModel.fromJson(doc.data());
          },
        ).toList();
      },
    );
  }

  @override
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _fireStore
        .collection(AppConstants.messages)
        .where(AppConstants.chatId, isEqualTo: chatId)
        .orderBy(AppConstants.timestamp, descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return MessageModel.fromJson(doc.data());
          },
        ).toList();
      },
    );
  }

  @override
  Future<void> createChat(ChatModel chat) async {
    try {
      await _fireStore
          .collection(AppConstants.chats)
          .doc(chat.id)
          .set(chat.toJson());
    } catch (e) {
      throw Exception('Failed to create chat ${e.toString()}');
    }
  }

  @override
  Future<String?> getChatId(List<String> participantIds) async {
    try {
      participantIds.sort();

      final querySnapshot = await _fireStore
          .collection(AppConstants.chats)
          .where(AppConstants.participantIds, isEqualTo: participantIds)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get chat id ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      final docSnapshot =
          await _fireStore.collection(AppConstants.users).doc(userId).get();

      if (docSnapshot.exists) {
        return UserModel.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user:$e');
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _fireStore.collection(AppConstants.chats).doc(messageId).update({
        AppConstants.isRead: true,
      });
    } catch (e) {
      throw Exception('Failed to mark message as read ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> searchUser(String query) async {
    try {
      final querySnapshot = await _fireStore
          .collection(AppConstants.users)
          .where(AppConstants.name, isGreaterThanOrEqualTo: query)
          .where(AppConstants.name, isGreaterThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs.map(
        (doc) {
          return UserModel.fromJson(doc.data());
        },
      ).toList();
    } catch (e) {
      throw Exception('Failed to search user ${e.toString()}');
    }
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      /// Add message to FireStore
      await _fireStore
          .collection(AppConstants.messages)
          .doc(message.id)
          .set(message.toJson());

      /// Update chat with last message details
      await _fireStore
          .collection(AppConstants.chats)
          .doc(message.chatId)
          .update({
        AppConstants.lastMessageAt: FieldValue.serverTimestamp(),
        AppConstants.lastMessageText: message.content,
        AppConstants.unreadCount: FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to send message ${e.toString()}');
    }
  }

  @override
  Future<String> uploadImage(String path) async {
    try {
      final file = File(path);
      final imageId = _uuid.v4();
      final Reference storageRef =
          _firebaseStorage.ref().child('${AppConstants.chatImages}/$imageId');

      await storageRef.putFile(file);

      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image $e');
    }
  }
}
