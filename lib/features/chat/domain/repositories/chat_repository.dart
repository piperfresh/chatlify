import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/chat/domain/model/chat_model.dart';
import 'package:chatlify/features/chat/domain/model/message_model.dart';

abstract class ChatRepository {
  Stream<List<ChatModel>> getUserChats(String userId);

  Stream<List<MessageModel>> getChatMessages(String chatId);

  Future<void> sendMessage(MessageModel message);

  Future<void> markMessageAsRead(String messageId);

  Future<void> createChat(ChatModel chat);

  Future<String?> getChatId(List<String> participantsId);

  Future<List<UserModel>> searchUser(String query);

  Future<UserModel?> getUserById(String userId);

  Future<String> uploadImage(String path);
}
