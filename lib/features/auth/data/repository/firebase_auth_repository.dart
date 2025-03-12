import 'package:chatlify/core/app_constants.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/auth/domain/repository/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider((ref) {
  print('Auth State change ${ref.watch(firebaseAuthRepositoryProvider).authStateChanges()}');
  return ref.watch(firebaseAuthRepositoryProvider).authStateChanges();
});

final firebaseAuthRepositoryProvider = Provider(
  (ref) {
    return FirebaseAuthRepository(
      firebaseAuth: FirebaseAuth.instance,
      fireStore: FirebaseFirestore.instance,
    );
  },
);

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({required this.firebaseAuth, required this.fireStore});

  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  final FirebaseAuth firebaseAuth;

  final FirebaseFirestore fireStore;

  @override
  Stream<User?> authStateChanges() {
    return firebaseAuth.authStateChanges();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) return null;

      final userData =
          await fireStore.collection(AppConstants.users).doc(user.uid).get();

      return UserModel.fromJson(userData.data()!);
    } catch (e) {
      throw Exception('Get current user failed ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signIn(
      {required String email, required String password}) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.user == null) {
        throw Exception('Sign in failed');
      }

      /// Update last active
      await fireStore
          .collection(AppConstants.users)
          .doc(userCredential.user?.uid)
          .update({'lastActive': FieldValue.serverTimestamp()});

      /// Get user data
      final userData = await fireStore
          .collection(AppConstants.users)
          .doc(userCredential.user?.uid)
          .get();

      return UserModel.fromJson(userData.data()!);
    } catch (e) {
      throw Exception('Sign in failed ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp(
      {required String name,
      required String email,
      required String password}) async {
    print(email);
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign up failed');
      }

      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      /// Save data to firebase
      await fireStore
          .collection(AppConstants.users)
          .doc(userCredential.user?.uid)
          .set(user.toJson());

      return user;
    } catch (e) {
      print('Error Error $e');
      throw Exception('Sign up failed ${e.toString()}');
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        return;
      }

      await fireStore.collection(AppConstants.users).doc(user.uid).update({
        'fcmToken': token,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Update fcm token failed ${e.toString()}');
    }
  }
}
