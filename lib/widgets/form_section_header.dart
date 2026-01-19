import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class FormSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const FormSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: kInkColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
