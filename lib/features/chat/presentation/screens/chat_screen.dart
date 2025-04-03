import 'dart:async';

import 'package:chatlify/core/common/app_snack_bar.dart';
import 'package:chatlify/core/common/app_textfield.dart';
import 'package:chatlify/core/common/loader.dart';
import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
import 'package:chatlify/features/chat/presentation/providers/chat_controller.dart';
import 'package:chatlify/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/helper.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId, required this.otherUser});

  final String chatId;
  final UserModel otherUser;

  @override
  ConsumerState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  Timer? _onlineStatusTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        ref.read(chatControllerProvider.notifier).markChatAsRead(widget.chatId);
      },
    );

    _onlineStatusTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) {
        ref.read(firebaseAuthRepositoryProvider).updateOnlineStatus(true);
      },
    );
  }

  void sendMessage() async {
    if (_messageController.text.isEmpty) {
      return;
    }

    final message = _messageController.text;
    _messageController.clear();
    try {
      await ref
          .read(chatControllerProvider.notifier)
          .sendTextMessage(widget.chatId, message.trim());
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        appSnackBar(context, 'Failed to send message: ${e.toString()}');
      }
    }
  }

  void _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _isUploading = true;
        });
        await ref
            .read(chatControllerProvider.notifier)
            .sendImageMessage(widget.chatId, image);

        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _onlineStatusTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessageProvider(widget.chatId));
    final userStream = ref.watch(chatUserStreamProvider(widget.otherUser.id));

    /// Add this listener to automatically mark new messages as read when visible
    messagesAsync.whenData(
      (messages) {
        if (messages.isNotEmpty) {
          final currentUserId =
              ref.read(authControllerProvider).value?.currentUser?.id;

          /// Find unread messages that aren't from the current user
          final unreadMessages = messages
              .where((message) =>
                  !message.isRead &&
                  message.senderId != currentUserId &&
                  !(message.readStatus[currentUserId] ?? false))
              .toList();

          /// Mark them as read if there are any
          if (unreadMessages.isNotEmpty) {
            for (final message in unreadMessages) {
              ref
                  .read(chatControllerProvider.notifier)
                  .markMessageAsRead(message.messageId);
            }
          }
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser.photoUrl != null
                  ? NetworkImage(widget.otherUser.photoUrl!)
                  : null,
              // backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              child: widget.otherUser.photoUrl == null
                  ? Text(
                      widget.otherUser.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            12.sbW,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontSize: 16),
                  ),
                  Consumer(builder: (context, ref, child) {
                    final userStream =
                        ref.watch(chatUserStreamProvider(widget.otherUser.id));
                    return userStream.when(
                      data: (user) {
                        if (user == null) return const SizedBox.shrink();

                        if (user.isOnline) {
                          return Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          );
                        } else if (user.lastActive != null) {
                          return Text(
                            'Last seen ${formatLastSeen(user.lastActive!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          );
                        } else {
                          return Text(
                            'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          );
                        }
                      },
                      error: (error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                      loading: () {
                        return Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      },
                    );
                  })
                ],
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implement call feature
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: messagesAsync.when(
            data: (messages) {
              if (messages.isEmpty) {
                return Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                );
              }

              return ListView.builder(
                    itemCount: messages.length,
                    controller: _scrollController,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId ==
                          ref
                              .watch(authControllerProvider)
                              .value
                              ?.currentUser
                              ?.id;
                  return MessageBubble(
                    userStream: userStream,
                    message: message,
                    isMe: isMe, onTap: () {},
                      );
                    },
                  );
                },
                error: (error, stackTrace) {
                  return Center(
                    child: Text(
                      'Error:${error.toString()}',
                      style:
                      TextStyle(color: Theme
                          .of(context)
                          .colorScheme
                          .error),
                    ),
                  );
                },
                loading: () {
                  return const Loader();
                },
              )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -1),
                  blurRadius: 5,
                )
              ],
            ),
            child: SafeArea(
                child: Row(
              children: [
                // IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                Expanded(
                  child: TextFieldWithTitle(
                    title: '',
                    isTitle: false,
                    controller: _messageController,
                    hintText: 'Type a message',
                    maxLines: null,
                  ),
                ),
                // IconButton(
                //   icon: const Icon(Icons.image),
                //   onPressed: _isUploading ? null : _pickImage,
                // ),
                IconButton(
                  icon: _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isUploading ? null : sendMessage,
                ),
              ],
            )),
          )
        ],
      ),
    );
  }
}
