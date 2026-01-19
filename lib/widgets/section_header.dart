import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionText = Text(
      actionLabel,
      style: theme.textTheme.bodySmall?.copyWith(
        color: kBrandColor,
        fontWeight: FontWeight.w600,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (onActionTap == null)
            actionText
          else
            GestureDetector(
              onTap: onActionTap,
              child: actionText,
            ),
        ],
      ),
    );
  }
}
