import 'package:chatlify/core/extension/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final bool isTitle;
  final void Function(bool)? onFocusChange;
  final FocusNode? focusNode;
  final String? errorText;
  final bool isErrorTextAvailable;

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
    this.isTitle = true,
    this.onFocusChange,
    this.focusNode,
    this.errorText,
    this.isErrorTextAvailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isTitle
            ? Text(title,
                style: Theme.of(context)
                .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 18.sp))
            : const SizedBox.shrink(),
        6.sbH,
        Focus(
          onFocusChange: onFocusChange,
          focusNode: focusNode,
          child: TextFormField(
            style: Theme.of(context).textTheme.bodySmall,
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
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white24 : Colors.black26,
                  )),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white24 : Colors.black26,
                  )),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white24 : Colors.black26,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                ),
              ),
              contentPadding: contentPadding ?? const EdgeInsets.all(10),
              filled: true,
              fillColor:
                  isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
              hintText: hintText,
              hintStyle: hintStyle ??
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 16.sp,
                      ),
            ),
          ),
        ),
        2.sbH,
        isErrorTextAvailable
            ? Text(
                errorText ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontSize: 12.sp,
                    ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
