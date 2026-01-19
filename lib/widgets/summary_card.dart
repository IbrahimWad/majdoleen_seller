import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class SummaryItem {
  final String label;
  final int value;
  final Color color;

  const SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class SummaryCard extends StatelessWidget {
  final SummaryItem item;

  const SummaryCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kInkColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }
}
