import 'package:chatlify/core/app_colors.dart';
import 'package:flutter/material.dart';

import 'loader.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.isLoading = false,
  });

  final void Function()? onPressed;
  final String buttonText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: AppColors.background,
          ),
          onPressed: onPressed,
          child: isLoading
              ? const Loader()
              : Text(
                  buttonText,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 20, color: AppColors.background),
                )),
    );
  }
}
