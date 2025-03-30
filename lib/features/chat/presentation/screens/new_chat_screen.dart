import 'package:chatlify/core/common/loader.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
import 'package:chatlify/features/chat/presentation/providers/all_user_provider.dart';
import 'package:chatlify/features/chat/presentation/providers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/app_textfield.dart';
import 'chat_screen.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authControllerProvider);
    final filteredUsers = ref.watch(filterUserProvider);
    final isCreatingChat = ref.watch(isCreatingChatProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Chat',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFieldWithTitle(
              title: '',
              isTitle: false,
              controller: searchController,
              hintText: 'Search User',
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
              child: Stack(
            children: [
              filteredUsers.when(
                data: (users) {
                  final filteredList =
                      currentUser.hasValue && currentUser.value != null
                          ? users
                              .where((user) =>
                                  user.id != currentUser.value?.currentUser?.id)
                              .toList()
                          : users;

                  if (filteredList.isEmpty) {
                    return const Center(
                      child: Text('No user found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final user = filteredList[index];
                      return NewChatTile(user: user, ref: ref);
                    },
                  );
                },
                error: (error, stackTrace) {
                  return Center(
                  child: Text(
                    'Error: $error',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                );
                },
                loading: () => const Loader(),
              ),
              if (isCreatingChat)
                const Center(
                  child: Loader(),
                ),
            ],
          ))
        ],
      ),
    );
  }
}

class NewChatTile extends StatelessWidget {
  const NewChatTile({
    super.key,
    required this.user,
    required this.ref,
  });

  final UserModel user;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: user.photoUrl != null
            ? Image.network(user.photoUrl!)
            : Text(user.name[0].toUpperCase()),
      ),
      title: Text(user.name),
      subtitle: Text(user.email, style: Theme.of(context).textTheme.bodySmall),
      onTap: () async {
        ref.read(isCreatingChatProvider.notifier).state = true;

        try {
          final chatId = await ref
              .read(chatControllerProvider.notifier)
              .startChat(user.id);

          if (chatId != null && context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: chatId,
                  otherUser: user,
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } finally {
          ref.read(isCreatingChatProvider.notifier).state = false;
        }
      },
    );
  }
}
