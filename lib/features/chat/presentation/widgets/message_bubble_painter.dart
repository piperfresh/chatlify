import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Custom shape for the bubble with the pointy part
class BubbleShape extends ShapeBorder {
  final bool isMe;
  final double radius;
  final double pointWidth;
  final double pointHeight;

  const BubbleShape({
    required this.isMe,
    this.radius = 1.0,
    this.pointWidth = 5.0,
    this.pointHeight = 4.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final width = rect.width;
    final height = rect.height;

    if (isMe) {
      // Top left corner
      path.moveTo(rect.left + radius, rect.top);

      // Top side
      path.lineTo(rect.right - radius - pointWidth, rect.top);

      // Top right corner
      path.arcToPoint(
        Offset(rect.right - pointWidth, rect.top + radius),
        radius: Radius.circular(radius),
      );

      // Right side
      path.lineTo(rect.right - pointWidth, rect.bottom - radius - pointHeight);
      path.arcToPoint(
        Offset(rect.right - pointWidth - radius, rect.bottom - pointHeight),
        radius: Radius.circular(radius),
      );

      // Point
      path.lineTo(rect.right - pointWidth, rect.bottom - pointHeight);
      path.lineTo(rect.right, rect.bottom);
      path.lineTo(
          rect.right - pointWidth - pointWidth, rect.bottom - pointHeight);

      // Bottom side
      path.lineTo(rect.left + radius, rect.bottom);

      // Bottom left corner
      path.arcToPoint(
        Offset(rect.left, rect.bottom - radius),
        radius: Radius.circular(radius),
      );

      // Left side
      path.lineTo(rect.left, rect.top + radius);

      // Top left corner
      path.arcToPoint(
        Offset(rect.left + radius, rect.top),
        radius: Radius.circular(radius),
      );
    } else {
      // Top right corner
      path.moveTo(rect.right - radius, rect.top);

      // Top side
      path.lineTo(rect.left + radius + pointWidth, rect.top);

      // Top left corner
      path.arcToPoint(
        Offset(rect.left + pointWidth, rect.top + radius),
        radius: Radius.circular(radius),
      );

      // Left side
      path.lineTo(rect.left + pointWidth, rect.bottom - radius - pointHeight);
      path.arcToPoint(
        Offset(rect.left + pointWidth + radius, rect.bottom - pointHeight),
        radius: Radius.circular(radius),
      );

      // Point
      path.lineTo(rect.left + pointWidth, rect.bottom - pointHeight);
      path.lineTo(rect.left, rect.bottom);
      path.lineTo(
          rect.left + pointWidth + pointWidth, rect.bottom - pointHeight);

      // Bottom side
      path.lineTo(rect.right - radius, rect.bottom);

      // Bottom right corner
      path.arcToPoint(
        Offset(rect.right, rect.bottom - radius),
        radius: Radius.circular(radius),
      );

      // Right side
      path.lineTo(rect.right, rect.top + radius);

      // Top right corner
      path.arcToPoint(
        Offset(rect.right - radius, rect.top),
        radius: Radius.circular(radius),
      );
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return BubbleShape(
      isMe: isMe,
      radius: radius * t,
      pointWidth: pointWidth * t,
      pointHeight: pointHeight * t,
    );
  }
}


// class WhatsAppBubbleShape extends ShapeBorder {
//   final bool isMe;
//   final double radius;
//   final double tailWidth;
//   final double tailHeight;
//
//   const WhatsAppBubbleShape({
//     required this.isMe,
//     this.radius = 18.0,
//     this.tailWidth = 8.0,
//     this.tailHeight = 6.0,
//   });
//
//   @override
//   EdgeInsetsGeometry get dimensions => EdgeInsets.only(
//     right: isMe ? tailWidth : 0,
//     left: isMe ? 0 : tailWidth,
//   );
//
//   @override
//   Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
//     return getOuterPath(rect, textDirection: textDirection);
//   }
//
//   @override
//   Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
//     final path = Path();
//     final tailPosition = rect.height * 0.7;
//
//     if (isMe) {
//       // Outgoing message (right side)
//       // Top left with rounded corner
//       path.moveTo(rect.left + radius, rect.top);
//
//       // Top edge
//       path.lineTo(rect.right - radius, rect.top);
//
//       // Top right corner
//       path.arcToPoint(
//         Offset(rect.right, rect.top + radius),
//         radius: Radius.circular(radius),
//         clockwise: true,
//       );
//
//       // Right edge until tail position
//       path.lineTo(rect.right, rect.top + tailPosition - tailHeight/2);
//
//       // Draw the tail pointing right
//       path.lineTo(rect.right + tailWidth, rect.top + tailPosition);
//       path.lineTo(rect.right, rect.top + tailPosition + tailHeight/2);
//
//       // Continuing right edge
//       path.lineTo(rect.right, rect.bottom - radius);
//
//       // Bottom right corner
//       path.arcToPoint(
//         Offset(rect.right - radius, rect.bottom),
//         radius: Radius.circular(radius),
//         clockwise: true,
//       );
//
//       // Bottom edge
//       path.lineTo(rect.left + radius, rect.bottom);
//
//       // Bottom left corner
//       path.arcToPoint(
//         Offset(rect.left, rect.bottom - radius),
//         radius: Radius.circular(radius),
//         clockwise: true,
//       );
//
//       // Left edge
//       path.lineTo(rect.left, rect.top + radius);
//
//       // Top left corner
//       path.arcToPoint(
//         Offset(rect.left + radius, rect.top),
//         radius: Radius.circular(radius),
//         clockwise: true,
//       );
//     } else {
//       // For incoming message bubble, we'll just create a rounded rectangle
//       // with no tail, similar to the image you shared
//
//       // Top left corner
//       path.moveTo(rect.left + radius, rect.top);
//
//       // Top edge
//       path.lineTo(rect.right - radius, rect.top);
//
//       // Top right corner
//       path.arcToPoint(
//         Offset(rect.right, rect.top + radius),
//         radius: Radius.circular(radius),
//         clockwise: true,
//       );
//
//       // Right edge
//       path.lineTo(rect.right, rect.bottom - radius);
//
//       // Bottom right corner
//       path.arcToPoint(
//         Offset(rect.right - radius, rect.bottom),
//         radius: Radius.circular(radius),
//         clockwise: true,
//       );
//
//       // Bottom edge
//       path.lineTo(rect.left + radius, rect.bottom);
//
//       // Bottom left corner
//       path.arcToPoint(
//         Offset(rect.left, rect.bottom - radius),
//         radius: Radius.circular(radius),
//         clockwise: true,
//       );
//
//       // Left edge
//       path.lineTo(rect.left, rect.top + radius);
//
//       // Top left corner
//       path.arcToPoint(
//         Offset(rect.left + radius, rect.top),
//         radius: Radius.circular(radius),
//         clockwise: true,
//       );
//     }
//
//     path.close();
//     return path;
//   }
//
//   @override
//   void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
//
//   @override
//   ShapeBorder scale(double t) {
//     return WhatsAppBubbleShape(
//       isMe: isMe,
//       radius: radius * t,
//       tailWidth: tailWidth * t,
//       tailHeight: tailHeight * t,
//     );
//   }
// }
