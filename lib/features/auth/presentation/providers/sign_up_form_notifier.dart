import 'package:chatlify/features/auth/presentation/providers/sign_up_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpFormNotifier extends StateNotifier<SignUpFormState> {
  SignUpFormNotifier() : super(SignUpFormState());

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

  void updateName(String name, {bool? isFocused}) {
    state = state.copyWith(
      name: name,
      isNameFocused: isFocused ?? state.isNameFocused,
    );
  }

  void setEmailFocused(bool isFocused) {
    state = state.copyWith(isEmailFocused: isFocused);
  }

  void setPasswordFocused(bool isFocused) {
    state = state.copyWith(isPasswordFocused: isFocused);
  }

  void setNameFocused(bool isFocused) {
    state = state.copyWith(isNameFocused: isFocused);
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

  String? validateName() {
    if (!state.isNameFocused) return null;

    if (state.name.isEmpty) {
      return 'Please enter name';
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

  bool get isEmailValid => state.email.isNotEmpty && state.email.contains('@');

  bool get isPasswordValid =>
      state.password.isNotEmpty && state.password.length >= 6;

  bool get isNameValid => state.name.isNotEmpty;

  bool get isFormValid =>
      state.email.isNotEmpty &&
      state.email.contains('@') &&
      state.name.isNotEmpty &&
      state.password.isNotEmpty &&
      state.password.length >= 6;
}

final signUpFormNotifierProvider =
    StateNotifierProvider<SignUpFormNotifier, SignUpFormState>((ref) {
  return SignUpFormNotifier();
});
