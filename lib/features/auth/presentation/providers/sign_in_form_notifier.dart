import 'package:chatlify/features/auth/presentation/providers/sign_in_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInFormNotifier extends StateNotifier<SignInFormState> {
  SignInFormNotifier() : super(SignInFormState());

  void updateEmail(String email, {bool? isFocused}) {
    state = state.copyWith(
      email: email,
      isEmailFocused: isFocused ?? state.isEmailFocused,
    );
  }

  void updatePassword(String password, {bool? isFocused}) {
    state = state.copyWith(
      password: password,
      isPasswordFocused: isFocused ?? state.isPasswordFocused,
    );
  }

  void setEmailFocus(bool isFocused) {
    state = state.copyWith(isEmailFocused: isFocused);
  }

  void setPasswordFocus(bool isFocused) {
    state = state.copyWith(isPasswordFocused: isFocused);
  }

  String? validateEmail() {
    if (!state.isEmailFocused) return null;

    if (state.email.isEmpty) {
      return 'Please enter email';
    } else if (!state.email.contains('@')) {
      return 'Please enter valid email';
    } else {
      return null;
    }
  }

  String? validatePassword() {
    if (!state.isPasswordFocused) return null;

    if (state.password.isEmpty) {
      return 'Please enter password';
    } else if (state.password.length < 6) {
      return 'Password must be at least 6 characters';
    } else {
      return null;
    }
  }

  bool get isFormValid =>
      state.password.isNotEmpty &&
      state.email.isNotEmpty &&
      state.password.length >= 6 &&
      state.email.contains('@');

  bool get isEmailValid => state.email.isNotEmpty && state.email.contains('@');

  bool get isPasswordValid =>
      state.password.isNotEmpty && state.password.length >= 6;
}

final signInFormNotifierProvider =
    StateNotifierProvider<SignInFormNotifier, SignInFormState>((ref) {
  return SignInFormNotifier();
});
