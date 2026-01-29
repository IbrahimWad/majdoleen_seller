import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final String price;
  final String period;
  final Color accent;
  final bool isRecommended;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.period,
    required this.accent,
    required this.features,
    this.isRecommended = false,
  });

  static List<SubscriptionPlan> buildPlans(AppLocalizations l10n) {
    return [
      SubscriptionPlan(
        id: 'free',
        name: l10n.subscriptionFreeName,
        description: l10n.subscriptionFreeDescription,
        price: l10n.subscriptionFreePrice,
        period: l10n.subscriptionForever,
        accent: kInfoColor,
        features: [
          l10n.subscriptionProductsLimit(50),
          l10n.subscriptionItemsLimit(500),
          l10n.subscriptionBasicAnalytics,
          l10n.subscriptionEmailSupport,
        ],
      ),
      SubscriptionPlan(
        id: 'plus',
        name: l10n.subscriptionPlusName,
        description: l10n.subscriptionPlusDescription,
        price: l10n.subscriptionPlusPrice,
        period: l10n.subscriptionPerMonth,
        accent: kBrandColor,
        isRecommended: true,
        features: [
          l10n.subscriptionProductsLimit(500),
          l10n.subscriptionItemsLimit(5000),
          l10n.subscriptionAdvancedAnalytics,
          l10n.subscriptionPrioritySupport,
        ],
      ),
      SubscriptionPlan(
        id: 'pro',
        name: l10n.subscriptionProName,
        description: l10n.subscriptionProDescription,
        price: l10n.subscriptionProPrice,
        period: l10n.subscriptionPerMonth,
        accent: kBrandDark,
        features: [
          l10n.subscriptionProductsUnlimited,
          l10n.subscriptionItemsUnlimited,
          l10n.subscriptionCustomInsights,
          l10n.subscriptionDedicatedSuccess,
        ],
      ),
    ];
  }
}
