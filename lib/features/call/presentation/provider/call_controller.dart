import 'package:chatlify/core/enum.dart';
import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
import 'package:chatlify/features/call/data/model/call_model.dart';
import 'package:chatlify/features/call/data/repository/call_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final incomingCallProvider = StreamProvider<CallModel?>(
  (ref) {
    final user = ref.watch(authControllerProvider).value?.currentUser;
    if (user == null) return Stream.value(null);
    return ref.watch(callRepositoryProvider).getIncomingCallStream(user.id);
  },
);

final activeCallProvider =
    StreamProvider.family<CallModel?, String>((ref, callId) {
  return ref.read(callRepositoryProvider).getActiveCallStream(callId);
});

final callControllerProvider =
    StateNotifierProvider<CallController, AsyncValue<CallModel?>>(
  (ref) {
    return CallController(ref, const Uuid());
  },
);

class CallController extends StateNotifier<AsyncValue<CallModel?>> {
  CallController(this._ref, this._uuid) : super(const AsyncValue.loading());

  final Ref _ref;
  final Uuid _uuid;

  Future<String?> initiateCall(
      String chatId, String receiverId, CallType callType) async {
    try {
      state = const AsyncValue.loading();

      final currentUser =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      /// Generate a unique channel name (typically chat ID + timestamp)
      final channelName = '${chatId}_${DateTime.now().millisecondsSinceEpoch}';

      /// Generate token (in real app, it's from the server)
      final token = await _ref
          .read(callRepositoryProvider)
          .generateCallToken(channelName, currentUser.id);

      final callId = _uuid.v4();
      final call = CallModel(
        callId: callId,
        chatId: chatId,
        callerId: currentUser.id,
        receiverId: receiverId,
        callType: callType,
        callStatus: CallStatus.pending,
        startTime: DateTime.now(),
        channelName: channelName,
        token: token,
      );

      await _ref.read(callRepositoryProvider).initiateCall(call);

      state = AsyncValue.data(call);
      return callId;
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      throw Exception('Error initiating call: $e');
    }
  }

  Future<void> acceptCall(CallModel call) async {
    try {
      await _ref
          .read(callRepositoryProvider)
          .updateCallStatus(call.callId, CallStatus.ongoing);
      // state = AsyncValue.data(call);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      throw Exception('Error accepting call: $e');
    }
  }

  Future<void> endCall(String callId) async {
    try {
      await _ref
          .read(callRepositoryProvider)
          .updateCallStatus(callId, CallStatus.ended);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      throw Exception('Error ending call: $e');
    }
  }

  Future<void> rejectCall(String callId) async {
    try {
      await _ref
          .read(callRepositoryProvider)
          .updateCallStatus(callId, CallStatus.rejected);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      throw Exception('Error rejecting call: $e');
    }
  }
}
