import 'package:chatlify/core/common/loader.dart';
import 'package:chatlify/core/extension/assets_extension.dart';
import 'package:chatlify/core/themes/theme_notifier.dart';
import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/presentation/screen/sign_in_screen.dart';
import 'package:chatlify/features/chat/presentation/providers/chat_controller.dart';
import 'package:chatlify/features/chat/presentation/screens/new_chat_screen.dart';
import 'package:chatlify/features/chat/presentation/widgets/chat_list_item.dart';
import 'package:chatlify/features/chat/presentation/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/model/message_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateStreamProvider);
    final chatState = ref.watch(chatControllerProvider);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: isDarkMode? Theme.of(context).cardColor:Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              icon: const Icon(Icons.dark_mode)),
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ));
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: chatState.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversation yet',
              message: 'Start a new chat with someone',
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final currentUserId = authState.value?.uid;

              ///Get the other user id's
              final otherUserId = chat.participantIds.firstWhere(
                (id) => id != currentUserId,
                orElse: () => chat.participantIds.first,
              );

              return Consumer(
                builder: (context, ref, child) {
                  final userAsyncValue =
                      ref.watch(chatUserStreamProvider(otherUserId));

                  return userAsyncValue.when(
                    data: (otherUser) {
                      if (otherUser == null) return const SizedBox();

                      final lastMessageAsync =
                          ref.watch(lastMessageProvider(chat.id));
                      return lastMessageAsync.when(
                        data: (lastMessageData) {
                          final lastMessage =
                              lastMessageData?.isNotEmpty == true
                                  ? lastMessageData!.first
                                  : null;
                          final isOutgoing =
                              lastMessage?.senderId == currentUserId;
                          final isRead = lastMessage != null && isOutgoing
                              ? _isMessageReadByReceiver(
                                  lastMessage, otherUserId)
                              : false;

                          return ChatListItem(
                            name: otherUser.name,
                            lastMessage:
                                chat.lastMessageText ?? 'Start a conversation',
                            time: chat.lastMessageAt,
                            unreadCount: chat.unreadCount[currentUserId] ?? 0,
                            isOutgoing: isOutgoing,
                            isRead: isRead,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return ChatScreen(
                                    chatId: chat.id,
                                    otherUser: otherUser,
                                  );
                                },
                              )).then(
                                (value) {
                                  /// When returning from the chat screen, reset the unread count
                                  ref
                                      .read(chatControllerProvider.notifier)
                                      .resetUnreadCount(chat.id);
                                },
                              );
                            },
                          );
                        },
                        loading: () => ChatListItem(
                          name: otherUser.name,
                          lastMessage:
                              chat.lastMessageText ?? 'Start a conversation',
                          time: chat.lastMessageAt,
                          unreadCount: chat.unreadCount[currentUserId] ?? 0,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return ChatScreen(
                                  chatId: chat.id,
                                  otherUser: otherUser,
                                );
                              },
                            ));
                          },
                        ),
                        error: (_, __) => ChatListItem(
                          name: otherUser.name,
                          lastMessage:
                              chat.lastMessageText ?? 'Start a conversation',
                          time: chat.lastMessageAt,
                          unreadCount: chat.unreadCount[currentUserId] ?? 0,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return ChatScreen(
                                  chatId: chat.id,
                                  otherUser: otherUser,
                                );
                              },
                            ));
                          },
                        ),
                      );
                    },
                    error: (error, stackTrace) {
                      return Center(
                        child: Text(error.toString()),
                      );
                    },
                    loading: () {
                      return const SizedBox.shrink();
                    },
                  );
                },
              );
            },
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Error: ${error.toString()}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        },
        loading: () {
          return const Loader();
        },
      ),
      floatingActionButton: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NewChatScreen(),
              ),
            );
          },
          child: SvgPicture.asset('new_chat'.svg)),
    );
  }

  /// Helper method to check if a message has been read by the receiver
  bool _isMessageReadByReceiver(MessageModel message, String receiverId) {
    return message.readStatus[receiverId] == true;
  }
}
