class SignInFormState{
  final String email;
  final String password;
  final bool isEmailFocused;
  final bool isPasswordFocused;

  SignInFormState({
    this.email = '',
    this.password = '',
    this.isEmailFocused = false,
    this.isPasswordFocused = false,
});

  SignInFormState copyWith({
    String? email,
    String? password,
    bool? isEmailFocused,
    bool? isPasswordFocused,
  }) {
    return SignInFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailFocused: isEmailFocused ?? this.isEmailFocused,
      isPasswordFocused: isPasswordFocused ?? this.isPasswordFocused,
    );
  }
}