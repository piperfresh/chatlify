import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/chat/domain/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';


class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onTap,
    required this.userStream,
  });

  final MessageModel message;
  final bool isMe;
  final VoidCallback onTap;
  final AsyncValue<UserModel?> userStream;

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isMe ? const Color(0xFF0B592C) : Theme.of(context).cardColor;
    final textColor =
        isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;
    final timeColor = isMe
        ? Colors.white.withOpacity(0.7)
        : Theme.of(context).textTheme.bodySmall?.color;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: isMe ? 0 : 10,
                right: isMe ? 10 : 0,
                top: 4,
                bottom: 4,
              ),
              child: IntrinsicWidth(
                child: Material(
                  borderRadius: BorderRadius.only(
                      bottomRight:
                          isMe ? Radius.zero : const Radius.circular(20),
                      topLeft: const Radius.circular(20),
                      bottomLeft:
                          !isMe ? Radius.zero : const Radius.circular(20),
                      topRight: const Radius.circular(20)),
                  color: bubbleColor,
                  child: GestureDetector(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          2.sbH,
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if(!isMe)...[
                                  Text(
                                    DateFormat('h:mm a')
                                        .format(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: timeColor,
                                    ),
                                  ),
                                ],
                                 4.sbW,
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  _buildReadStatus(message, isMe,
                                      userStream: userStream),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadStatus(MessageModel message, bool isMe,
      {required AsyncValue<UserModel?> userStream}) {
    if (!isMe) return const SizedBox.shrink();
    bool isReadByRecipients = false;

    if (message.readStatus.isNotEmpty) {
      isReadByRecipients = message.readStatus.entries
          .where((entry) => entry.key != message.senderId)
          .any((entry) => entry.value == true);
    }
    return Row(
      children: [
        Text(
          DateFormat('HH:mm a').format(message.timestamp),
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
          ),
        ),
        Icon(
          isReadByRecipients ? Icons.done_all : Icons.done_all,
          color:
              isReadByRecipients ? Colors.blue : Colors.white.withOpacity(0.7),
        ),
        4.sbW,
      ],
    );
  }
}
