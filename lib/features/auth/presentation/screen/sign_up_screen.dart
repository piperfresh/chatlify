import 'package:chatlify/core/common/app_snack_bar.dart';
import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
import 'package:chatlify/features/auth/presentation/providers/sign_up_form_notifier.dart';
import 'package:chatlify/features/auth/presentation/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/app_textfield.dart';
import '../../../../core/common/primary_button.dart';
import '../widgets/account_existed_or_not.dart';



class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpAuth = ref.watch(authControllerProvider);
    final signUpFormState = ref.watch(signUpFormNotifierProvider);
    final signUpFormNotifier = ref.read(signUpFormNotifierProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              100.sbH,
              Text('Sign Up', style: Theme.of(context).textTheme.titleLarge),
              50.sbH,
              TextFieldWithTitle(
                title: 'Email',
                controller: _emailController,
                onChanged: (email) => signUpFormNotifier.updateEmail(email),
                onFocusChange: (hasFocus) {
                  signUpFormNotifier.setEmailFocused(hasFocus);
                },
                errorText: signUpFormNotifier.validateEmail(),
                isErrorTextAvailable: !signUpFormNotifier.isEmailValid,
              ),
              5.sbH,
              TextFieldWithTitle(
                title: 'Name',
                controller: _nameController,
                onChanged: (name) => signUpFormNotifier.updateName(name),
                onFocusChange: (hasFocus) {
                  signUpFormNotifier.setNameFocused(hasFocus);
                },
                errorText: signUpFormNotifier.validateName(),
                isErrorTextAvailable: !signUpFormNotifier.isNameValid,
              ),
              5.sbH,
              TextFieldWithTitle(
                title: 'Password',
                controller: _passwordController,
                onChanged: (password) =>
                    signUpFormNotifier.updatePassword(password),
                onFocusChange: (hasFocus) {
                  signUpFormNotifier.setPasswordFocused(hasFocus);
                },
                errorText: signUpFormNotifier.validatePassword(),
                isErrorTextAvailable: !signUpFormNotifier.isPasswordValid,
              ),
              10.sbH,
              PrimaryButton(
                  isLoading: signUpAuth.isLoading,
                  isActive: signUpFormNotifier.isFormValid,
                  onPressed: () async {
                    final isSignUp = await ref
                        .read(authControllerProvider.notifier)
                        .signUp(
                            _emailController.text.trim(),
                            _nameController.text.trim(),
                            _passwordController.text.trim());

                    if (isSignUp) {
                      if (context.mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return const LoginScreen();
                              },
                            ));
                      }
                    } else {
                      appSnackBar(context, signUpAuth.error.toString());
                    }
                  },
                  buttonText: 'Sign Up'),
              15.sbH,
              AccountExistedOrNot(
                text: 'Already have an account? ',
                buttonText: 'Sign In',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
