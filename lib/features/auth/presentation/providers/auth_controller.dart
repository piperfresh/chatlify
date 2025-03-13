import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final user =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();
      state = AsyncValue.data(user!);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref
          .read(firebaseAuthRepositoryProvider)
          .signIn(email: email, password: password);
      state = AsyncValue.data(user);
      return true;
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }

  Future<bool> signUp(String email, String name, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref
          .read(firebaseAuthRepositoryProvider)
          .signUp(name: name, email: email, password: password);
      state = AsyncValue.data(user);
      return true;
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(firebaseAuthRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>(
  (ref) => AuthController(ref),
);
