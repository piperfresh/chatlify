import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();

  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({required String name, required String email, required String password});

  Future<void> signOut();

  Future<void> updateFcmToken(String token);

  Future<UserModel?> getCurrentUser();

  Future<void> updateOnlineStatus(bool isOnline);
}
