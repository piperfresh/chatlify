import 'package:chatlify/core/app_constants.dart';
import 'package:chatlify/core/enum.dart';
import 'package:chatlify/features/call/data/model/call_model.dart';
import 'package:chatlify/features/call/domain/repository/call_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final callRepositoryProvider = Provider<CallRepository>(
  (ref) {
    return CallRepositoryImpl(
      FirebaseFirestore.instance,
      const Uuid(),
    );
  },
);

class CallRepositoryImpl implements CallRepository {
  final FirebaseFirestore _fireStore;
  final Uuid _uuid;

  CallRepositoryImpl(this._fireStore, this._uuid);

  @override
  Future<String> initiateCall(CallModel callModel) async {
    try {
      await _fireStore
          .collection(AppConstants.calls)
          .doc(callModel.callId)
          .set(callModel.toJson());

      return callModel.callId;
    } catch (e) {
      throw Exception("Error initiating call: $e");
    }
  }

  @override
  Future<void> updateCallStatus(String callId, CallStatus callStatus) async {
    try {
      await _fireStore.collection(AppConstants.calls).doc(callId).update({
        "status": callStatus.name,
        if (callStatus == CallStatus.ended)
          'endTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update call status: $e');
    }
  }

  @override
  Stream<CallModel?> getActiveCallStream(String callId) {
    return _fireStore
        .collection(AppConstants.calls)
        .doc(callId)
        .snapshots()
        .map(
      (snapshot) {
        if (snapshot.exists) {
          return CallModel.fromJson(snapshot.data()!);
        }
        return null;
      },
    );
  }

  @override
  Stream<CallModel?> getIncomingCallStream(String userId) {
    return _fireStore
        .collection(AppConstants.calls)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: CallStatus.pending.name)
        .snapshots()
        .map(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return CallModel.fromJson(snapshot.docs.first.data());
        }
        return null;
      },
    );
  }

  @override
  Future<String> generateCallToken(String channelName, String userId) async {
    try {
      // In a real app, we will make an API call to your server
      // For demo, we'll just return a placeholder
      return "demo-token-${_uuid.v4()}";

      // Real implementation would be like:
      // final response = await http.get(Uri.parse('your-token-server?channel=$channelName&uid=$userId'));
      // return jsonDecode(response.body)['token'];
    } catch (e) {
      throw Exception('Failed to generate call token: ${e.toString()}');
    }
  }
}
