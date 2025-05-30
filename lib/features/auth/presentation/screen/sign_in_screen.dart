import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
import 'package:chatlify/features/auth/presentation/widgets/account_existed_or_not.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/common.dart';
import '../../../home/presentation/screens/home.dart';
import '../providers/sign_in_form_notifier.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginAuth = ref.watch(authControllerProvider);
    final signInFormState = ref.watch(signInFormNotifierProvider);
    final signInFormNotifier = ref.read(signInFormNotifierProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              100.sbH,
              Text('Sign In', style: Theme.of(context).textTheme.titleLarge),
              50.sbH,
              TextFieldWithTitle(
                title: 'Email',
                controller: _emailController,
                onChanged: (email) {
                  signInFormNotifier.updateEmail(email,isFocused: true);
                },
                onFocusChange: (hasFocus) {
                  signInFormNotifier.setEmailFocus(hasFocus);
                },
                errorText: signInFormNotifier.validateEmail(),
                isErrorTextAvailable: signInFormNotifier.validateEmail() != null,
              ),
              5.sbH,
              TextFieldWithTitle(
                title: 'Password',
                controller: _passwordController,
                onChanged: (password) {
                  signInFormNotifier.updatePassword(password);
                },
                onFocusChange: (hasFocus) {
                  signInFormNotifier.setPasswordFocus(hasFocus);
                },
                obscureText: true,
                errorText: signInFormNotifier.validatePassword(),
                isErrorTextAvailable: !signInFormNotifier.isPasswordValid,
              ),
              30.sbH,
              PrimaryButton(
                isLoading: loginAuth.isLoading,
                isActive: signInFormNotifier.isFormValid,
                onPressed: () async {
                  final isLogin = await ref
                      .read(authControllerProvider.notifier)
                      .signIn(_emailController.text.trim(),
                          _passwordController.text.trim());
                  if (isLogin) {
                    if (context.mounted) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Home(),
                          ));
                    }
                  } else {
                    if (context.mounted) {
                      appSnackBar(context, loginAuth.error.toString());
                    }
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
                      builder: (_) => const SignInScreen(),
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
