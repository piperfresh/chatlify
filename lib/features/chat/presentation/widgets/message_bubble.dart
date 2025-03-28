import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/chat/domain/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class MessageBubble extends StatelessWidget {
//   const MessageBubble(
//       {super.key,
//       required this.message,
//       required this.isMe,
//       required this.onTap});
//
//   final MessageModel message;
//   final bool isMe;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         child: Material(
//           color: isMe
//               ? Theme.of(context).primaryColor
//               : Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(12),
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(12),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (message.type == MessageType.text)
//                     Text(
//                       message.content,
//                       style: TextStyle(
//                           color: isMe
//                               ? Colors.blue
//                               : Theme.of(context).textTheme.bodyLarge?.color),
//                     )
//                   else if (message.type == MessageType.image)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         message.content,
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Center(
//                             child: CircularProgressIndicator(
//                               value: loadingProgress.expectedTotalBytes != null
//                                   ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                   : null,
//                             ),
//                           );
//                         },
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             height: 100,
//                             color: Colors.grey.withOpacity(0.3),
//                             child: Icon(
//                               Icons.broken_image,
//                               color: Theme.of(context).colorScheme.error,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   4.sbH,
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         DateFormat('HH:mm').format(message.timestamp),
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: isMe
//                               ? Colors.white.withOpacity(0.7)
//                               : Theme.of(context).textTheme.bodySmall?.color,
//                         ),
//                       ),
//                       if (isMe)
//                         Padding(
//                           padding: const EdgeInsets.only(left: 4),
//                           child: Icon(
//                             message.isRead ? Icons.done_all : Icons.done,
//                             size: 14,
//                             color: Colors.white.withOpacity(0.7),
//                           ),
//                         )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onTap,
  });

  final MessageModel message;
  final bool isMe;
  final VoidCallback onTap;

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
            // The content with proper intrinsic sizing
            Container(
              margin: EdgeInsets.only(
                left: isMe ? 0 : 10,
                right: isMe ? 10 : 0,
                top: 4,
                bottom: 4,
              ),
              child: IntrinsicWidth(
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: bubbleColor,
                  // shape: BubbleShape(isMe: isMe),
                  child: GestureDetector(
                    onTap: onTap,
                    // borderRadius: BorderRadius.circular(20),
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
                                  _buildReadStatus(message, isMe),
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

  bool _isReadByAll(MessageModel message) {
    // Check if all participants except the sender have read the message
    if (message.readStatus.isEmpty) return false;

    for (var entry in message.readStatus.entries) {
      // Skip the sender
      if (entry.key == message.senderId) continue;

      // If any recipient hasn't read it, return false
      if (!entry.value) return false;
    }

    return true;
  }

  // Widget _buildReadStatus(MessageModel message, bool isMe) {
  //   if (!isMe) return const SizedBox.shrink();
  //   final bool isRead = message.readStatus.values.every((status) => status);
  //   return Row(
  //     children: [
  //       Icon(isRead ? Icons.done_all : Icons.done),
  //       4.sbW,
  //       Text(
  //         DateFormat('HH:mm').format(message.timestamp),
  //         style: const TextStyle(
  //           fontSize: 12,
  //           color: Colors.grey,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildReadStatus(MessageModel message, bool isMe) {
    if (!isMe) return const SizedBox.shrink();
    bool isReadByRecipients = false;

    if (message.readStatus.isNotEmpty) {
      isReadByRecipients = message.readStatus.entries
          .where((entry) => entry.key != message.senderId)
          .any((entry) => entry.value == true);
    }
    return Row(
      children: [
        Icon(
          isReadByRecipients ? Icons.done_all : Icons.done,
          color:
              isReadByRecipients ? Colors.blue : Colors.white.withOpacity(0.7),
        ),
        4.sbW,
        Text(
          DateFormat('HH:mm a').format(message.timestamp),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// class MessageBubble extends StatelessWidget {
//   const MessageBubble({
//     super.key,
//     required this.message,
//     required this.isMe,
//     required this.onTap,
//   });
//
//   final MessageModel message;
//   final bool isMe;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final bubbleColor = isMe ? const Color(0xFF0F5F3D) : Theme.of(context).cardColor;
//     final textColor = isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;
//     final timeColor = isMe
//         ? Colors.white.withOpacity(0.7)
//         : Theme.of(context).textTheme.bodySmall?.color;
//
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           child: Material(
//             color: bubbleColor,
//             shape: WhatsAppBubbleShape(isMe: isMe),
//             child: InkWell(
//               onTap: onTap,
//               borderRadius: BorderRadius.circular(18),
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(
//                   isMe ? 12 : 12, // Standard left padding
//                   8,               // Top padding
//                   isMe ? 16 : 12,  // Right padding (extra for outgoing messages)
//                   8,               // Bottom padding
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       message.content,
//                       style: TextStyle(
//                         color: textColor,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Text(
//                           DateFormat('h:mm a').format(message.timestamp),
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: timeColor,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         if (isMe)
//                           Icon(
//                             message.isRead ? Icons.done_all : Icons.done,
//                             size: 14,
//                             color: timeColor,
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }