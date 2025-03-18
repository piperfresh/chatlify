import 'package:chatlify/features/auth/domain/models/user_model.dart';

class AuthState {
  final List<UserModel>? users;
  final UserModel? currentUser;

  AuthState({this.users, this.currentUser});

  AuthState copyWith({
    List<UserModel>? users,
    UserModel? currentUser,
  }) {
    return AuthState(
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}
