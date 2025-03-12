import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AccountExistedOrNot extends StatelessWidget {
  const AccountExistedOrNot({
    super.key,
    required this.text,
    required this.onTap, required this.buttonText,
  });

  final String text;
  final VoidCallback onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
          text: TextSpan(
              text: text,
              style: Theme.of(context).textTheme.bodySmall,
              children: [
            TextSpan(
                recognizer: TapGestureRecognizer()..onTap = onTap,
                text: buttonText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ))
          ])),
    );
  }
}
