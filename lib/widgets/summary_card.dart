import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_shadows.dart';

class SummaryItem {
  final String label;
  final int value;
  final Color color;
  final IconData? icon;

  const SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
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
    final icon = item.icon ?? Icons.insights_outlined;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 96),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withOpacity(0.15)),
          boxShadow: kSoftShadow,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: item.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.65),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.value.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: item.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
