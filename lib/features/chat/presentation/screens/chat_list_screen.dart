import 'package:chatlify/core/common/loader.dart';
import 'package:chatlify/core/themes/theme_notifier.dart';
import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/auth/presentation/screen/login_screen.dart';
import 'package:chatlify/features/chat/presentation/providers/chat_controller.dart';
import 'package:chatlify/features/chat/presentation/screens/chat_screen.dart';
import 'package:chatlify/features/chat/presentation/screens/new_chat_screen.dart';
import 'package:chatlify/features/chat/presentation/widgets/chat_list_item.dart';
import 'package:chatlify/features/chat/presentation/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';

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
    print('This is build ${ref.watch(authControllerProvider.notifier).getAllUsers()}');
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
              return FutureBuilder<UserModel?>(
                future: ref
                    .read(chatControllerProvider.notifier)
                    .getUserById(chat.participantIds.firstWhere(
                      (id) => id != authState.value?.uid,
                      orElse: () => chat.participantIds.first,
                    )),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  final otherUser = snapshot.data;
                  print('This is the other user $otherUser');

                  if (otherUser == null) return const SizedBox();
                  return ChatListItem(
                    name: otherUser.name,
                    lastMessage: chat.lastMessageText ?? 'Start a conversion',
                    time: chat.lastMessageAt,
                    unreadCount: chat.unreadCount[authState.value?.uid] ?? 0,
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
                  );
                },
              );
            },
          );
        },
        error: (error, stackTrace) {
          print(error.toString());
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NewChatScreen(),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
