import 'package:chatlify/core/extension/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem(
      {super.key,
      required this.name,
      this.photoUrl,
      required this.lastMessage,
      required this.time,
      required this.unreadCount,
    required this.onTap,
    // this.currentUserId,
    // this.lastMessageSenderId,
    this.isOutgoing = false,
    this.isRead = false,
  });

  final String name;
  final String? photoUrl;
  final String lastMessage;
  final DateTime time;
  final int unreadCount;
  final VoidCallback onTap;

  // final String? lastMessageSenderId;
  // final String? currentUserId;
  final bool isOutgoing;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    // final bool isRead = unreadCount == 0;
    // final bool isOutGoing = currentUserId == lastMessageSenderId;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl!) : null,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              child: photoUrl == null
                  ? Text(name[0].toUpperCase(),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18))
                  : null,
            ),
            16.sbW,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        formatChatTime(time),
                        style: TextStyle(
                          color: unreadCount > 0
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  4.sbH,
                  Row(
                    children: [
                      if (isOutgoing)
                        Icon(
                          isRead ? Icons.done_all : Icons.done,
                          color: isRead
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                        ),
                      if (isOutgoing) 4.sbW,
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unreadCount > 0
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE').format(dateTime); // Day name
    } else {
      return DateFormat('MM/dd/yyyy').format(dateTime);
    }
  }
}
