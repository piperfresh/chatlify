import 'dart:developer';

import 'package:chatlify/core/common/app_snack_bar.dart';
import 'package:chatlify/core/common/app_textfield.dart';
import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
import 'package:chatlify/features/auth/presentation/screen/sign_up_screen.dart';
import 'package:chatlify/features/auth/presentation/widgets/account_existed_or_not.dart';
import 'package:chatlify/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign In', style: Theme.of(context).textTheme.titleLarge),
            50.sbH,
            TextFieldWithTitle(
              title: 'Email',
              controller: _emailController,
            ),
            10.sbH,
            TextFieldWithTitle(
              title: 'Password',
              controller: _passwordController,
            ),
            30.sbH,
            PrimaryButton(
              isLoading: ref.watch(authControllerProvider).isLoading,
              onPressed: () async {
                final isLogin = await ref
                    .read(authControllerProvider.notifier)
                    .signIn(_emailController.text.trim(),
                        _passwordController.text.trim());
                if (isLogin) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatListScreen(),
                      ));
                } else {
                  appSnackBar(context,
                      ref.watch(authControllerProvider).error.toString());
                }

                log('${_emailController.text}${_passwordController.text}');
              },
              buttonText: 'Sign in',
            ),
            15.sbH,
            AccountExistedOrNot(
              text: 'Don\'t have an account? ',
              buttonText: 'Sign Up',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SignUpScreen(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
