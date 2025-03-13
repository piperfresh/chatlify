import 'package:chatlify/core/app_colors.dart';
import 'package:chatlify/core/extension/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWithTitle extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final bool? isBigSize;
  final int? maxLines;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const TextFieldWithTitle({
    super.key,
    required this.title,
    this.validator,
    this.controller,
    this.hintText,
    this.hintStyle,
    this.contentPadding,
    this.isBigSize = false,
    this.maxLines = 1,
    this.onTap,
    this.inputFormatters,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 18, color: AppColors.darkCardColor)),
       6.sbH,
        TextFormField(
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: 16, color: AppColors.darkCardColor),
          controller: controller,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          onTap: onTap,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.darkCardColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.darkCardColor)),
            contentPadding: contentPadding ?? const EdgeInsets.all(10),
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            hintStyle: hintStyle ??
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 16,
                    ),
          ),
        ),
      ],
    );
  }
}
