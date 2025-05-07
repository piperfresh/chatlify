import 'package:chatlify/features/call/data/model/call_model.dart';
import 'package:chatlify/features/call/presentation/provider/call_controller.dart';
import 'package:chatlify/features/call/presentation/screens/incoming_call_screen.dart';
import 'package:chatlify/features/chat/presentation/providers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/domain/models/user_model.dart';

class CallListener extends ConsumerStatefulWidget {
  final Widget child;

  const CallListener({super.key, required this.child});

  @override
  ConsumerState createState() => _CallListenerState();
}

class _CallListenerState extends ConsumerState<CallListener> {
  String? _currentCallId;
  bool _isShowingCallScreen = false;

  @override
  Widget build(BuildContext context) {
    // Use ref.listen with extra safety checks
    ref.listen<AsyncValue<CallModel?>>(
      incomingCallProvider,
      (previous, next) {
        // Safely handle state updates
        _handleCallUpdate(context, next);
      },
    );

    return widget.child;
  }

  // Handle call updates in a way that's safe for widget lifecycle
  void _handleCallUpdate(
      BuildContext context, AsyncValue<CallModel?> callState) {
    if (!mounted) return;

    callState.whenData((call) async {
      if (!mounted) return;

      if (call != null && !_isShowingCallScreen) {
        // Only proceed if we're not already showing a call screen
        try {
          _isShowingCallScreen = true;
          _currentCallId = call.callId;

          final caller = await ref
              .read(chatControllerProvider.notifier)
              .getUserById(call.callerId);

          print('This is the caller: ${caller?.name}');

          if (caller != null && mounted) {
            // Use a post-frame callback to ensure the build is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showIncomingCall(context, call, caller);
              }
            });
          }
        } catch (e) {
          print("Error handling incoming call: $e");
          _isShowingCallScreen = false;
        }
      }
    });
  }

  void _showIncomingCall(
      BuildContext context, CallModel call, UserModel caller) {
    // Only show if still mounted and not already showing
    if (!mounted || _isShowingCallScreen == false) return;

    try {
      // Navigate with safer approach
      Navigator.of(context, rootNavigator: true)
          .push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => IncomingCallScreen(
            call: call,
            caller: caller,
          ),
        ),
      )
          .then((_) {
        // Reset flags only if still mounted
        if (mounted) {
          setState(() {
            _isShowingCallScreen = false;
            _currentCallId = null;
          });
        }
      });
    } catch (e) {
      print("Navigation error: $e");
      // Reset state on error
      if (mounted) {
        setState(() {
          _isShowingCallScreen = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Ensure proper cleanup
    _isShowingCallScreen = false;
    _currentCallId = null;
    super.dispose();
  }
}

// class _CallListenerState extends ConsumerState<CallListener> {
//   BuildContext? _dialogContext;
//   String? _currentCallId;
//
//   @override
//   Widget build(BuildContext context) {
//     ref.watch(incomingCallProvider);
//     ref.listen<AsyncValue<CallModel?>>(
//       incomingCallProvider,
//       (previous, next) {
//         next.whenData(
//           (call) async {
//             print("Call listener received call: ${call?.callId}");
//
//             if (call != null && mounted) {
//               // Check if this is a new call or one we're already handling
//               if (_currentCallId != call.callId) {
//                 print("New incoming call detected: ${call.callId}");
//                 _currentCallId = call.callId;
//
//                 // Get caller details
//                 final caller = await ref
//                     .read(chatControllerProvider.notifier)
//                     .getUserById(call.callerId);
//
//                 print("Caller info: ${caller?.name}");
//
//                 if (caller != null && mounted) {
//                   // Show incoming call screen
//                   showIncomingCall(context, call, caller);
//                 } else {
//                   print("Couldn't find caller info or context not mounted");
//                 }
//               }
//             } else if (call == null && _dialogContext != null) {
//               // Call ended or was rejected
//               print("Call ended or rejected, closing dialog");
//               Navigator.of(_dialogContext!).pop();
//               _dialogContext = null;
//               _currentCallId = null;
//             }
//           },
//         );
//       },
//     );
//     return widget.child;
//   }
//
//   void showIncomingCall(
//       BuildContext context, CallModel call, UserModel caller) {
//     print("Showing incoming call screen for call: ${call.callId}");
//
//     // Add a safeguard to check if we can actually navigate
//     if (!mounted || !Navigator.of(context, rootNavigator: true).canPop()) {
//       print("Navigation context not ready, delaying call screen");
//       // Try again after a short delay
//       Future.delayed(Duration(milliseconds: 500), () {
//         if (mounted) showIncomingCall(context, call, caller);
//       });
//       return;
//     }
//
//     Navigator.of(context, rootNavigator: true)
//         .push(MaterialPageRoute(
//       fullscreenDialog: true,
//       builder: (context) {
//         _dialogContext = context;
//         return IncomingCallScreen(
//           call: call,
//           caller: caller,
//         );
//       },
//     ))
//         .then((_) {
//       print("Call screen closed");
//       _dialogContext = null;
//       _currentCallId = null;
//     });
//   }
// //   ref.listen<AsyncValue<CallModel?>>(
// //     incomingCallProvider,
// //     (previous, next) {
// //       print('Incoming call: $next');
// //       next.whenData(
// //         (call) async {
// //           print('Call arrived: $call');
// //           // if (call != null && _dialogContext != null) {
// //           //   /// Get caller details
// //           //   final caller = await ref
// //           //       .read(chatControllerProvider.notifier)
// //           //       .getUserById(call.callerId);
// //           //   if (caller != null && context.mounted) {
// //           //     Navigator.of(context).push(MaterialPageRoute(
// //           //       builder: (context) {
// //           //         _dialogContext = context;
// //           //         return IncomingCallScreen(
// //           //           call: call,
// //           //           caller: caller,
// //           //         );
// //           //       },
// //           //     )).then(
// //           //       (_) {
// //           //         _dialogContext = null;
// //           //       },
// //           //     );
// //           //   } else if (call == null && _dialogContext != null) {
// //           //     Navigator.of(_dialogContext!).pop();
// //           //     _dialogContext = null;
// //           //   }
// //           // }
// //           //!
// //           // if (call != null) {
// //           //   final caller = await ref
// //           //       .read(chatControllerProvider.notifier)
// //           //       .getUserById(call.callerId);
// //           //   print('Call is not null');
// //           //   // Navigator.of(context).push(MaterialPageRoute(
// //           //   //   builder: (context) {
// //           //   //     print('Navigating to IncomingCallScreen');
// //           //   //     _dialogContext = context;
// //           //   //     return IncomingCallScreen(
// //           //   //       call: call,
// //           //   //       caller: caller!,
// //           //   //     );
// //           //   //   },
// //           //   // ));
// //           //   if (caller != null && context.mounted) {
// //           //     print('Call and context is not null');
// //           //     Navigator.of(context).push(MaterialPageRoute(
// //           //       builder: (context) {
// //           //         print('Navigating to IncomingCallScreen');
// //           //         _dialogContext = context;
// //           //         return IncomingCallScreen(
// //           //           call: call,
// //           //           caller: caller,
// //           //         );
// //           //       },
// //           //     )).then((_) {
// //           //       _dialogContext = null;
// //           //     });
// //           //   } else if (_dialogContext != null) {
// //           //     Navigator.of(_dialogContext!).pop();
// //           //     _dialogContext = null;
// //           //   }
// //           // }
// //           if (call != null && mounted) {
// //             // Get caller details
// //             final caller = await ref
// //                 .read(chatControllerProvider.notifier)
// //                 .getUserById(call.callerId);
// //
// //             if (caller != null && mounted) {
// //               // Use context directly - now it's safe because CallListener is inside MaterialApp
// //               if (_dialogContext == null) {
// //                 // Only show if not already showing a call screen
// //                 showIncomingCall(context, call, caller);
// //               }
// //             }
// //           } else if (call == null && _dialogContext != null) {
// //             // Call ended or was rejected
// //             Navigator.of(_dialogContext!).pop();
// //             _dialogContext = null;
// //           }
// //         },
// //       );
// //     },
// //   );
// //   return widget.child;
// // }
//
// // void showIncomingCall(
// //     BuildContext context, CallModel call, UserModel caller) {
// //   // Use a method to handle navigation
// //   Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
// //     builder: (context) {
// //       _dialogContext = context;
// //       return IncomingCallScreen(
// //         call: call,
// //         caller: caller,
// //       );
// //     },
// //   )).then((_) {
// //     _dialogContext = null;
// //   });
// // }
// }
