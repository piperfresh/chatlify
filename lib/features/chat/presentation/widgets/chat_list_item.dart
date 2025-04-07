import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/chat/presentation/widgets/user_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_colors.dart';
import '../providers/chat_controller.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem(
      {super.key,
      required this.name,
      this.photoUrl,
      required this.lastMessage,
      required this.time,
      required this.unreadCount,
    required this.onTap,
    this.isOutgoing = false,
    this.isRead = false,
    required this.otherUser,
  });

  final String name;
  final String? photoUrl;
  final String lastMessage;
  final DateTime time;
  final int unreadCount;
  final VoidCallback onTap;
  final bool isOutgoing;
  final bool isRead;
  final UserModel otherUser;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Consumer(builder: (context, ref, child) {
              final userStream =
                  ref.watch(userChatStreamProvider(otherUser.id));
              return Stack(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl!) : null,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.5),
                    child: photoUrl == null
                        ? Text(name[0].toUpperCase(),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))
                        : null,
                  ),
                  Positioned(
                      top: 35.h,
                      left: 45.w,
                      child: userStream.when(
                        data: (user) {
                          if (user!.isOnline) {
                            return const UserStatusIndicator(
                              color: Colors.green,
                            );
                          } else {
                            return const UserStatusIndicator(
                              color: Colors.grey,
                            );
                          }
                        },
                        error: (error, stackTrace) {
                          return const UserStatusIndicator(
                            color: Colors.grey,
                          );
                        },
                        loading: () {
                          return const SizedBox.shrink();
                        },
                      )),
                ],
              );
            }),
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        formatChatTime(time),
                        style: TextStyle(
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),
                  4.sbH,
                  Consumer(builder: (context, ref, child) {
                    final userStream =
                        ref.watch(userChatStreamProvider(otherUser.id));
                    return _buildMessageStatusIcon(userStream, context);
                  })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatusIcon(
      AsyncValue<UserModel?> userStream, BuildContext context) {
    return Row(
      children: [
        if (isOutgoing)
          Icon(
            size: 14.sp,
            isRead ? Icons.done_all : Icons.done_all,
            color: isRead
                ? Colors.blue
                : Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.6),
          ),
          // userStream.when(
          //   data: (user) {
          //     if (user!.isOnline) {
          //       return Icon(
          //         size: 14.sp,
          //         isRead ? Icons.done_all : Icons.done_all,
          //         color: isRead
          //             ? Theme.of(context).colorScheme.primary
          //             : Theme.of(context)
          //                 .colorScheme
          //                 .onSurface
          //                 .withOpacity(0.6),
          //       );
          //     } else {
          //       return Icon(
          //         size: 14.sp,
          //         Icons.done,
          //         color:
          //             Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          //       );
          //     }
          //   },
          //   error: (error, stackTrace) {
          //     return Icon(
          //       size: 14.sp,
          //       Icons.done,
          //       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          //     );
          //   },
          //   loading: () {
          //     return const SizedBox.shrink();
          //   },
          // ),
        if (isOutgoing) 4.sbW,
        Expanded(
          child: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
        ),
        if (unreadCount > 0)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.blue,
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
