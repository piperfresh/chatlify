class SignUpFormState {
  final bool isNameTouched;
  final bool isEmailTouched;
  final bool isPasswordTouched;

  SignUpFormState({
    this.isEmailTouched = false,
    this.isNameTouched = false,
    this.isPasswordTouched = false,
  });

  SignUpFormState copyWith({
    bool? isNameTouched,
    bool? isEmailTouched,
    bool? isPasswordTouched,
  }) {
    return SignUpFormState(
      isNameTouched: isNameTouched ?? this.isNameTouched,
      isEmailTouched: isEmailTouched ?? this.isEmailTouched,
      isPasswordTouched: isPasswordTouched ?? this.isPasswordTouched,
    );
  }
}
