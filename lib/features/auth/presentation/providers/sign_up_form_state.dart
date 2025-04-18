class SignUpFormState {
  final String email;
  final String password;
  final String name;
  final bool isEmailFocused;
  final bool isPasswordFocused;
  final bool isNameFocused;

  SignUpFormState({
    this.email = '',
    this.password = '',
    this.name = '',
    this.isEmailFocused = false,
    this.isPasswordFocused = false,
    this.isNameFocused = false,
  });

  SignUpFormState copyWith({
    String? email,
    String? password,
    String? name,
    bool? isEmailFocused,
    bool? isPasswordFocused,
    bool? isNameFocused,
  }) {
    return SignUpFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      isEmailFocused: isEmailFocused ?? this.isEmailFocused,
      isPasswordFocused: isPasswordFocused ?? this.isPasswordFocused,
      isNameFocused: isNameFocused ?? this.isNameFocused,
    );
  }
}
