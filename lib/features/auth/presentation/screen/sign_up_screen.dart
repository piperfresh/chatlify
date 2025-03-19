import 'package:chatlify/core/common/app_snack_bar.dart';
import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
import 'package:chatlify/features/auth/presentation/providers/sign_up_form_notifier.dart';
import 'package:chatlify/features/auth/presentation/screen/login_screen.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String? _emailCheck(String? value, bool touched) {
    if (!touched) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    } else if (!value.contains('@')) {
      return 'Please enter valid email';
    }
    return null;
  }

  String? _passwordCheck(String? value, bool touched) {
    if (!touched) return null;

    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _nameCheck(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final signUpAuth = ref.watch(authControllerProvider);
    final signUpFormState = ref.watch(signUpFormNotifierProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                100.sbH,
                Text('Sign Up', style: Theme.of(context).textTheme.titleLarge),
                50.sbH,
                TextFieldWithTitle(
                  title: 'Email',
                  controller: _emailController,
                  validator: (value) =>
                      _emailCheck(value, signUpFormState.isEmailTouched),
                  onChanged: (p0) {
                    setState(() {});
                  },
                  onFocusChange: (hasFocus) {
                    if (!hasFocus && !signUpFormState.isEmailTouched) {
                      ref
                          .read(signUpFormNotifierProvider.notifier)
                          .setEmailTouched();
                    }
                  },
                ),
                10.sbH,
                TextFieldWithTitle(
                  title: 'Name',
                  controller: _nameController,
                  validator: _nameCheck,
                  onChanged: (p0) {
                    setState(() {});
                  },
                ),
                10.sbH,
                TextFieldWithTitle(
                  title: 'Password',
                  controller: _passwordController,
                  validator: (value) => _passwordCheck(value, signUpFormState.isPasswordTouched),
                  onFocusChange: (hasFocus) {
                    if(!hasFocus && !signUpFormState.isPasswordTouched){
                      ref.read(signUpFormNotifierProvider.notifier).setPasswordTouched();
                    }
                  },
                  onChanged: (p0) {
                    setState(() {});
                  },
                ),
                10.sbH,
                PrimaryButton(
                  isLoading: signUpAuth.isLoading,
                  onPressed: _formKey.currentState == null ||
                          !_formKey.currentState!.validate()
                      ? null
                      : () async {
                          final isSignUp = await ref
                              .read(authControllerProvider.notifier)
                              .signUp(
                                  _emailController.text.trim(),
                                  _nameController.text.trim(),
                                  _passwordController.text.trim());

                          if (isSignUp) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return const LoginScreen();
                              },
                            ));
                          } else {
                            appSnackBar(context, signUpAuth.error.toString());
                          }
                        },
                  buttonText: 'Sign Up',
                ),
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
      ),
    );
  }
}
