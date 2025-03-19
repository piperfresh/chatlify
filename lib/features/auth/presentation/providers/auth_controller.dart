import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends StateNotifier<AsyncValue<AuthState>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final user =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();
      state = AsyncValue.data(AuthState(currentUser: user));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<List<UserModel?>> getAllUsers() async {
    state = const AsyncValue.loading();
    try {
      final users =
          await _ref.read(firebaseAuthRepositoryProvider).getAllUser();

      if (state.hasValue && state.value != null) {
        state = AsyncValue.data(state.value!
            .copyWith(users: users.whereType<UserModel>().toList()));
      }

      return users.whereType<UserModel>().toList();
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return [];
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref
          .read(firebaseAuthRepositoryProvider)
          .signIn(email: email, password: password);
      state = AsyncValue.data(AuthState(currentUser: user));
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
      state = AsyncValue.data(AuthState(currentUser: user));
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
      state = AsyncValue.data(AuthState(users: null, currentUser: null));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthState>>(
  (ref) => AuthController(ref),
);
