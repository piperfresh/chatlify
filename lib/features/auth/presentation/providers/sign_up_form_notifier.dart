import 'package:chatlify/features/auth/presentation/providers/sign_up_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpFormNotifier extends StateNotifier<SignUpFormState> {
  SignUpFormNotifier() : super(SignUpFormState());

  void setEmailTouched() {
    state = state.copyWith(isEmailTouched: true);
  }

  void setNameTouched() {
    state = state.copyWith(isNameTouched: true);
  }

  void setPasswordTouched() {
    state = state.copyWith(isPasswordTouched: true);
  }
}

final signUpFormNotifierProvider =
    StateNotifierProvider<SignUpFormNotifier, SignUpFormState>((ref) {
  return SignUpFormNotifier();
});
