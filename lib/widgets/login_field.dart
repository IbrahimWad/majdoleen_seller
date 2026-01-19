import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';

class LoginField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? hintStyle;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const LoginField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.suffixIcon,
    this.onSubmitted,
    this.inputFormatters,
    this.hintStyle,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseLabelSize = theme.textTheme.bodyMedium?.fontSize ?? 14;
    final labelSize = baseLabelSize * 1.15;
    final fieldVerticalPadding = 16.0 * 1.15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: kInkColor.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            fontSize: labelSize,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintStyle,
            prefixIcon: Icon(
              icon,
              size: 22,
              color: kBrandColor,
            ),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              vertical: fieldVerticalPadding,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: kInkColor.withOpacity(0.2),
                width: 1.2,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kBrandColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
