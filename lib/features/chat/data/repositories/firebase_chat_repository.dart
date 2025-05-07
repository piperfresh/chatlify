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
  Future<List<UserModel>> searchUser(String query) async {
    try {
      final querySnapshot = await _fireStore
          .collection(AppConstants.users)
          .where(AppConstants.name, isGreaterThanOrEqualTo: query)
          .where(AppConstants.name, isLessThanOrEqualTo: '$query\uf8ff')
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
      /// Initialize read status with all participants set to false except sender
      final chatSnapshot = await _fireStore
          .collection(AppConstants.chats)
          .doc(message.chatId)
          .get();

      if (!chatSnapshot.exists) {
        throw Exception('Chat not found');
      }

      final chatData = chatSnapshot.data()!;
      final List<String> participantIds =
          List<String>.from(chatData['participantIds']);

      Map<String, bool> readStatus = {};
      for (String participantId in participantIds) {
        /// Sender has already "read" their own message
        readStatus[participantId] = participantId == message.senderId;
      }

      /// Create a copy of the message with the read status
      final updatedMessage = MessageModel(
        messageId: message.messageId,
        chatId: message.chatId,
        senderId: message.senderId,
        content: message.content,
        type: message.type,
        timestamp: message.timestamp,
        isRead: false,
        readStatus: readStatus,
      );

      /// Add message to FireStore
      await _fireStore
          .collection(AppConstants.messages)
          .doc(message.messageId)
          .set(updatedMessage.toJson());

      /// Update chat with last message details and increment unread count for each participant except sender
      Map<String, dynamic> chatUpdates = {
        AppConstants.lastMessageAt: FieldValue.serverTimestamp(),
        AppConstants.lastMessageText: message.content,
      };

      /// Increment unread count for each participant except sender
      for (String participantId in participantIds) {
        if (participantId != message.senderId) {
          chatUpdates['unreadCount.$participantId'] = FieldValue.increment(1);
        } else {
          /// Mark the message as read for the sender
          chatUpdates['unreadCount.$participantId'] = 0;
        }
      }

      await _fireStore
          .collection(AppConstants.chats)
          .doc(message.chatId)
          .update(chatUpdates);
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

  @override
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      /// Update the unread count for this user to 0
      Map<String, dynamic> update = {};
      update['unreadCount.$userId'] = 0;

      await _fireStore
          .collection(AppConstants.chats)
          .doc(chatId)
          .update(update);

      /// Also mark all unread messages as read
      final unreadMessages = await _fireStore
          .collection(AppConstants.messages)
          .where('chatId', isEqualTo: chatId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .get();

      /// Create a batch to update multiple documents at once
      final batch = _fireStore.batch();

      for (var doc in unreadMessages.docs) {
        Map<String, dynamic> readStatusUpdate = {};
        readStatusUpdate['readStatus.$userId'] = true;
        readStatusUpdate['isRead'] = true;

        batch.update(doc.reference, readStatusUpdate);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark chat as read ${e.toString()}');
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      /// Get the message first
      final docSnapshot = await _fireStore
          .collection(AppConstants.messages)
          .doc(messageId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Message not found');
      }

      ///Update the message read status
      Map<String, dynamic> readStatusUpdate = {};
      readStatusUpdate['readStatus.$userId'] = true;
      readStatusUpdate['isRead'] = true;

      await _fireStore
          .collection(AppConstants.messages)
          .doc(messageId)
          .update(readStatusUpdate);
    } catch (e) {
      throw Exception('Failed to mark message as read ${e.toString()}');
    }
  }

  Future<ChatModel?> getChatDetails(String chatId) async {
    try {
      final docSnapshot = await _fireStore
          .collection(AppConstants.chats)
          .doc(chatId)
          .get();

      if (docSnapshot.exists) {
        return ChatModel.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get chat details: $e');
    }
  }
}
