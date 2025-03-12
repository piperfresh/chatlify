import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign Up', style: Theme.of(context).textTheme.titleLarge),
            50.sbH,
            TextFieldWithTitle(
              title: 'Email',
              controller: _emailController,
            ),
            10.sbH,
            TextFieldWithTitle(
              title: 'Name',
              controller: _nameController,
            ),
            10.sbH,
            TextFieldWithTitle(
                title: 'Password', controller: _passwordController),
            10.sbH,
            PrimaryButton(
              isLoading: ref.watch(authControllerProvider).isLoading,
              onPressed: () async {
                try {
                  await ref.read(authControllerProvider.notifier).signUp(
                      _emailController.text.trim(),
                      _nameController.text.trim(),
                      _passwordController.text.trim());
                } catch (e) {
                  print('Sign Up Error $e');
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
