import 'package:chatlify/core/enum.dart';
import 'package:chatlify/features/call/data/model/call_model.dart';

abstract class CallRepository {
  Future<String> initiateCall(CallModel callModel);

  Future<void> updateCallStatus(String callId, CallStatus callStatus);

  Stream<CallModel?> getIncomingCallStream(String userId);

  Stream<CallModel?> getActiveCallStream(String callId);

  Future<String> generateCallToken(String channelName, String userId);
}
