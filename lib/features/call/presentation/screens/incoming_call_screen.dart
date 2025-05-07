import 'package:chatlify/core/enum.dart';
import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/call/data/model/call_model.dart';
import 'package:chatlify/features/call/presentation/provider/call_controller.dart';
import 'package:chatlify/features/call/presentation/screens/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncomingCallScreen extends ConsumerWidget {
  final CallModel call;
  final UserModel caller;

  const IncomingCallScreen(
      {super.key, required this.call, required this.caller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            'Incoming ${call.callType == CallType.video ? 'Video' : 'Voice'} Call',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          40.sbH,
          CircleAvatar(
            radius: 70,
            backgroundImage:
                caller.photoUrl != null ? NetworkImage(caller.photoUrl!) : null,
            child: caller.photoUrl == null
                ? Text(
                    caller.name[0],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                    ),
                  )
                : null,
          ),
          20.sbH,
          Text('is calling you',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              )),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    await ref
                        .read(callControllerProvider.notifier)
                        .rejectCall(call.callId);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  onPressed: () async {
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) {
                          return CallScreen(call: call, otherUser: caller);
                        },
                      ));
                    }
                  },
                  backgroundColor: Colors.green,
                  child: Icon(call.callType == CallType.video
                      ? Icons.videocam
                      : Icons.call),
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}
