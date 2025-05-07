import 'dart:async';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chatlify/core/app_constants.dart';
import 'package:chatlify/core/enum.dart';
import 'package:chatlify/features/call/data/model/call_model.dart';
import 'package:chatlify/features/call/presentation/provider/call_controller.dart';
import 'package:chatlify/features/call/presentation/provider/call_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../auth/domain/models/user_model.dart';

class Params {
  final CallModel? call;
  final UserModel? otherUser;

  Params({this.call, this.otherUser});
}

// final callProvider = StateNotifierProvider.family<CallProvider, CallState,
//     ({CallModel call, UserModel otherUser})>(
//   (ref, params) {
//     return CallProvider(ref, params.call, params.otherUser);
//   },
// );

final callProvider =
    StateNotifierProvider.family<CallProvider, CallState, Params>(
  (ref, params) {
    print('Params: ${params.call}, ${params.otherUser}');
    return CallProvider(ref, params.call, params.otherUser);
  },
);

class CallProvider extends StateNotifier<CallState> {
  final CallModel? call;
  final UserModel? otherUser;
  final Ref ref;

  CallProvider(this.ref, this.call, this.otherUser) : super(CallState()) {
    initializeAgora();
  }

  // Future<void> initializeAgora() async {
  //   // Request permissions first
  //   await [Permission.microphone, Permission.camera].request();
  //
  //   /// RTC engine instance
  //   state.copyWith(engine: createAgoraRtcEngine());
  //   await state.engine
  //       ?.initialize(const RtcEngineContext(appId: AppConstants.agoraAppId));
  //   print('Engine initialized');
  //
  //   state.engine?.registerEventHandler(RtcEngineEventHandler(
  //     onJoinChannelSuccess: (connection, elapsed) {
  //       state.copyWith(localUserJoined: true);
  //     },
  //     onUserJoined: (connection, remoteUid, elapsed) {
  //       state.copyWith(remoteUserJoined: true);
  //     },
  //     onUserOffline: (connection, remoteUid, reason) {
  //       state.copyWith(localUserJoined: false);
  //       endCall();
  //     },
  //   ));
  //
  //   if (call?.callType == CallType.video) {
  //     await state.engine?.enableVideo();
  //     await state.engine?.startPreview();
  //   } else {
  //     await state.engine?.disableVideo();
  //   }
  //
  //   await state.engine?.setEnableSpeakerphone(state.speakerOn);
  //
  //   await state.engine?.joinChannel(
  //     token: call?.token ?? '',
  //     channelId: call?.channelName ?? '',
  //     uid: 0,
  //     options: const ChannelMediaOptions(),
  //   );
  //
  //   if (call?.callStatus == CallStatus.pending) {
  //     await ref.read(callControllerProvider.notifier).acceptCall(call!);
  //   }
  // }

  // Future<void> initializeAgora() async {
  //   try {
  //     // First check if permissions are granted
  //     final permissionStatus =
  //         await [Permission.microphone, Permission.camera].request();
  //
  //     // Verify permissions were granted
  //     if (permissionStatus[Permission.microphone] != PermissionStatus.granted) {
  //       debugPrint('Microphone permission not granted');
  //       return;
  //     }
  //
  //     if (call?.callType == CallType.video &&
  //         permissionStatus[Permission.camera] != PermissionStatus.granted) {
  //       debugPrint('Camera permission not granted');
  //       return;
  //     }
  //
  //     // Create RTC engine instance
  //     final engine = createAgoraRtcEngine();
  //     await engine.initialize(const RtcEngineContext(
  //       appId: AppConstants.agoraAppId,
  //     ));
  //
  //     // Update the state with the engine
  //     state = state.copyWith(engine: engine);
  //
  //     // Register event handlers
  //     engine.registerEventHandler(RtcEngineEventHandler(
  //       onJoinChannelSuccess: (connection, elapsed) {
  //         debugPrint('Successfully joined channel: ${connection.channelId}');
  //         state = state.copyWith(localUserJoined: true);
  //
  //         // Set speaker phone after successfully joining
  //         engine.setEnableSpeakerphone(state.speakerOn);
  //       },
  //       onUserJoined: (connection, remoteUid, elapsed) {
  //         debugPrint('Remote user joined: $remoteUid');
  //         state = state.copyWith(remoteUserJoined: true);
  //       },
  //       onUserOffline: (connection, remoteUid, reason) {
  //         debugPrint('Remote user offline: $remoteUid, reason: $reason');
  //         state = state.copyWith(remoteUserJoined: false);
  //         endCall();
  //       },
  //       onError: (err, msg) {
  //         debugPrint('Agora error: $err, $msg');
  //       },
  //     ));
  //
  //     // Enable video if it's a video call
  //     if (call?.callType == CallType.video) {
  //       await engine.enableVideo();
  //       await engine.startPreview();
  //     } else {
  //       await engine.disableVideo();
  //     }
  //
  //     // Validate channel parameters
  //     final token = call?.token;
  //     final channelName = call?.channelName;
  //
  //     if (token == null || token.isEmpty) {
  //       debugPrint('Token is null or empty');
  //       return;
  //     }
  //
  //     if (channelName == null || channelName.isEmpty) {
  //       debugPrint('Channel name is null or empty');
  //       return;
  //     }
  //
  //     // Log before joining to help debug
  //     debugPrint(
  //         'Attempting to join channel: $channelName with token: ${token.substring(0, min(10, token.length))}...');
  //
  //     await engine.leaveChannel();
  //
  //     // Join the channel
  //     await engine.joinChannel(
  //       token: token,
  //       channelId: channelName,
  //       uid: 0,
  //       options: const ChannelMediaOptions(),
  //     );
  //
  //     // Update call status if needed
  //     if (call?.callStatus == CallStatus.pending) {
  //       await ref.read(callControllerProvider.notifier).acceptCall(call!);
  //     }
  //   } catch (e) {
  //     debugPrint('Error in initializeAgora: $e');
  //     // You may want to update state or show error to user
  //   }
  // }

  Future<void> initializeAgora() async {
    try {
      // Log key values first to verify what we're working with
      debugPrint('App ID: ${AppConstants.agoraAppId}');
      debugPrint('Token : ${call?.token}');
      debugPrint(
          'Token: ${call?.token?.substring(0, min(10, call?.token?.length ?? 0))}...');
      debugPrint('Channel Name: ${call?.channelName}');

      // Request permissions
      await [Permission.microphone, Permission.camera].request();


      // Create engine with explicit error checking
      final engine = createAgoraRtcEngine();
      try {
        await engine.initialize(const RtcEngineContext(
          appId: AppConstants.agoraAppId,
        ));
        debugPrint('Engine initialized successfully');
      } catch (e) {
        debugPrint('Engine initialization failed: $e');
        return;
      }


      // if (engine != null) return;
      // Update state with engine
      state = state.copyWith(engine: engine);
     final callId =await engine.getCallId();
     print('Engine Call ID: $callId');

      print('LEGOLAS');

      // Set up event handlers
      engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('Channel join successful');
          state = state.copyWith(localUserJoined: true);
        },
        onError: (errorCode, msg) {
          debugPrint('Agora error callback: $errorCode, $msg');
        },
      ));

      // Video setup
      if (call?.callType == CallType.video) {
        await engine.enableVideo();
        await engine.startPreview();
      }

      // Try joining with more specific error handling
      try {
        // Make sure we have valid parameters
        if (call?.token == null || call!.token!.isEmpty) {
          throw Exception('Token is empty or null');
        }

        if (call?.channelName == null || call!.channelName!.isEmpty) {
          throw Exception('Channel name is empty or null');
        }

        // Join with timeout to catch hanging calls
        debugPrint('Attempting to join channel: ${call?.channelName}');
        await engine
            .joinChannel(
          token: call!.token!,
          channelId: call!.channelName!,
          uid: 0,
          options: const ChannelMediaOptions(),
        )
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException('Joining channel timed out');
        });

        debugPrint('Join channel call completed');
      } catch (e) {
        debugPrint('Error joining channel: $e');
        // Clean up resources on join failure
        await engine.release();
        return;
      }
    } catch (e) {
      debugPrint('Error in initializeAgora root: $e');
    }
  }

  void toggleMute() {
    final  newMuted = !state.muted;
    state.engine?.muteLocalAudioStream(newMuted);
    state = state.copyWith(muted: newMuted);
  }

  void toggleSpeaker() {
    state.engine?.setEnableSpeakerphone(!state.speakerOn);
    state.copyWith(speakerOn: !state.speakerOn);
  }

  void toggleCamera() {
    if (call?.callType == CallType.voice) {
      return;
    }
    if (!state.cameraOff) {
      state.engine?.disableVideo();
    } else {
      state.engine?.enableVideo();
    }
    state.copyWith(cameraOff: !state.cameraOff);
  }

  void switchCamera() {
    if (call?.callType == CallType.voice) {
      return;
    }
    state.engine?.switchCamera();
  }

  Future<void> endCall() async {
    await ref.read(callControllerProvider.notifier).endCall(call!.callId);
  }
}
