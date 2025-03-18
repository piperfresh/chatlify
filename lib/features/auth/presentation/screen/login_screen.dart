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

  String? _emailCheck(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    } else if (!value.contains('@')) {
      return 'Please enter valid email';
    }
    return null;
  }

  String? _passwordCheck(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginAuth = ref.watch(authControllerProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                100.sbH,
                Text('Sign In', style: Theme.of(context).textTheme.titleLarge),
                50.sbH,
                TextFieldWithTitle(
                  title: 'Email',
                  controller: _emailController,
                  validator: _emailCheck,
                  onChanged: (p0) {
                    setState(() {});
                  },
                ),
                10.sbH,
                TextFieldWithTitle(
                  title: 'Password',
                  controller: _passwordController,
                  onChanged: (p0) {
                    setState(() {});
                  },
                  validator: _passwordCheck,
                ),
                30.sbH,
                PrimaryButton(
                  isLoading: ref.watch(authControllerProvider).isLoading,
                  onPressed: _formKey.currentState == null ||
                          !_formKey.currentState!.validate()
                      ? null
                      : () async {
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
                            appSnackBar(context, loginAuth.error.toString());
                          }
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
        ),
      ),
    );
  }
}
