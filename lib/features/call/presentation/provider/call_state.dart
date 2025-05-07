import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/call/data/model/call_model.dart';

class CallState {
  final bool speakerOn;
  final bool muted;
  final bool cameraOff;
  final bool remoteUserJoined;
  final bool localUserJoined;
  final RtcEngine? engine;

  CallState(
      {this.speakerOn = true,
      this.muted = false,
      this.cameraOff = false,
      this.remoteUserJoined = false,
      this.localUserJoined = false,
      this.engine});

  CallState copyWith({
    bool? speakerOn,
    bool? muted,
    bool? cameraOff,
    bool? remoteUserJoined,
    bool? localUserJoined,
    CallModel? call,
    UserModel? otherUser,
    RtcEngine? engine,
  }) {
    return CallState(
      speakerOn: speakerOn ?? this.speakerOn,
      muted: muted ?? this.muted,
      cameraOff: cameraOff ?? this.cameraOff,
      remoteUserJoined: remoteUserJoined ?? this.remoteUserJoined,
      localUserJoined: localUserJoined ?? this.localUserJoined,
      engine: engine ?? this.engine,
    );
  }
}
