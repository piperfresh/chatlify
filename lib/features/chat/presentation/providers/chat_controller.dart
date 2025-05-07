import 'package:chatlify/core/enum.dart';
import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/chat/data/repositories/firebase_chat_repository.dart';
import 'package:chatlify/features/chat/domain/model/chat_model.dart';
import 'package:chatlify/features/chat/domain/model/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// To track the last message sender
final lastMessageProvider = StreamProvider.family<List<MessageModel>?, String>(
      (ref, chatId) {
    return ref.watch(chatControllerProvider.notifier)
        .getChatMessages(chatId)
        .map((messages) => messages.isNotEmpty ? [messages.first] : []);
  },
);

/// To get particular chat messages
final chatMessageProvider = StreamProvider.family<List<MessageModel>, String>(
  (ref, chatId) {
    return ref.watch(chatControllerProvider.notifier).getChatMessages(chatId);
  },
);

/// To get list of user chat
final userChatStreamProvider =
    StreamProvider.family<UserModel?, String>((ref, userId) {
  return ref.read(firebaseChatRepositoryProvider).getUserStream(userId);
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, AsyncValue<List<ChatModel>>>(
  (ref) {
    return ChatController(ref, const Uuid());
  },
);

class ChatController extends StateNotifier<AsyncValue<List<ChatModel>>> {
  ChatController(this._ref, this._uuid) : super(const AsyncValue.loading()) {
    _loadChats();
  }

  final Ref _ref;
  final Uuid _uuid;

  Future<void> _loadChats() async {
    final user =
        await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();

    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    _ref.read(firebaseChatRepositoryProvider).getUserChats(user.id).listen(
        (chats) {
      state = AsyncValue.data(chats);
    }, onError: (error) {
      state = AsyncValue.error(error, StackTrace.current);
    });
  }

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _ref.read(firebaseChatRepositoryProvider).getChatMessages(chatId);
  }

  Future<String?> startChat(String userId) async {
    try {
      final currentUser =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();

      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      /// Check if chats already exists
      final participantIds = [currentUser.id, userId];
      final existingChatId = await _ref
          .read(firebaseChatRepositoryProvider)
          .getChatId(participantIds);

      if (existingChatId != null) {
        return existingChatId;
      }

      final chatId = _uuid.v4();
      final chat = ChatModel(
          id: chatId,
          participantIds: participantIds,
          createdAt: DateTime.now(),
          lastMessageAt: DateTime.now(),
          unreadCount: {userId: 0, currentUser.id: 0});

      await _ref.read(firebaseChatRepositoryProvider).createChat(chat);
      return chatId;
    } catch (e) {
      throw Exception('Failed to start chat: ${e.toString()}');
    }
  }

  Future<void> sendTextMessage(String chatId, String text) async {
    try {
      final currentUser =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();

      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      final message = MessageModel(
        messageId: _uuid.v4(),
        chatId: chatId,
        senderId: currentUser.id,
        content: text,
        type: MessageType.text,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _ref.read(firebaseChatRepositoryProvider).sendMessage(message);
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  Future<void> sendImageMessage(String chatId, XFile image) async {
    try {
      final currentUser =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();
      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      /// Upload image to storage
      final imageUrl = await _ref
          .read(firebaseChatRepositoryProvider)
          .uploadImage(image.path);

      final message = MessageModel(
        messageId: _uuid.v4(),
        chatId: chatId,
        senderId: currentUser.id,
        content: imageUrl,
        type: MessageType.image,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _ref.read(firebaseChatRepositoryProvider).sendMessage(message);
    } catch (e) {
      throw Exception('Failed to send image message: ${e.toString()}');
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    try {
      final currentUser =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();

      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      await _ref
          .read(firebaseChatRepositoryProvider)
          .markChatAsRead(chatId, currentUser.id);
    } catch (e) {
      throw Exception('Failed to mark chat as read: ${e.toString()}');
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      final currentUser =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();

      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      await _ref
          .read(firebaseChatRepositoryProvider)
          .markMessageAsRead(messageId, currentUser.id);
    } catch (e) {
      throw Exception('Failed to mark message as read: ${e.toString()}');
    }
  }

  Future<List<UserModel>> searchUser(String query) async {
    try {
      return await _ref.read(firebaseChatRepositoryProvider).searchUser(query);
    } catch (e) {
      throw Exception('Failed to search user ${e.toString()}');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _ref
          .read(firebaseChatRepositoryProvider)
          .getUserById(userId);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> resetUnreadCount(String chatId) async {
    try {
      final currentUser =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();

      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      await _ref
          .read(firebaseChatRepositoryProvider)
          .markChatAsRead(chatId, currentUser.id);
    } catch (e) {
      throw Exception('Failed to reset unread count: ${e.toString()}');
    }
  }
}

