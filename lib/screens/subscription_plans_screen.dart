import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_navigation.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/form_section_header.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  static const String routeName = AppRoutes.subscriptionPlans;

  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  String _currentPlanId = 'free';

  void _showMessage(String message) {
    showAppSnackBar(context, message);
  }

  Future<void> _requestPlanChange(_PlanTier plan) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PlanConfirmSheet(plan: plan),
    );

    if (confirmed == true) {
      setState(() {
        _currentPlanId = plan.id;
      });
      _showMessage(l10n.subscriptionUpdatedMessage(plan.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final plans = [
      _PlanTier(
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
      _PlanTier(
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
      _PlanTier(
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

    final currentPlan =
        plans.firstWhere((plan) => plan.id == _currentPlanId, orElse: () {
      return plans.first;
    });

    return Scaffold(
      appBar: const SellerAppBar(),
      drawer: const SellerDrawer(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: FormSectionHeader(
                  title: l10n.subscriptionPlansTitle,
                  subtitle: l10n.subscriptionPlansSubtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _CurrentPlanCard(
                  label: l10n.subscriptionCurrentLabel,
                  title: l10n.subscriptionCurrentSummary(currentPlan.name),
                  subtitle: l10n.subscriptionCurrentHint,
                  accent: currentPlan.accent,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.subscriptionPlansSectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: plans
                      .map(
                        (plan) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlanCard(
                            plan: plan,
                            isCurrent: plan.id == _currentPlanId,
                            onSelect: plan.id == _currentPlanId
                                ? null
                                : () => _requestPlanChange(plan),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.subscriptionFooterNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SellerBottomBar(
        selectedIndex: -1,
        onTap: (index) => handleNavTap(context, index),
      ),
    );
  }
}

class _PlanTier {
  final String id;
  final String name;
  final String description;
  final String price;
  final String period;
  final Color accent;
  final bool isRecommended;
  final List<String> features;

  const _PlanTier({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.period,
    required this.accent,
    required this.features,
    this.isRecommended = false,
  });
}

class _CurrentPlanCard extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final Color accent;

  const _CurrentPlanCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.verified_rounded, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _PlanTier plan;
  final bool isCurrent;
  final VoidCallback? onSelect;

  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final highlightColor = plan.accent;
    final badgeLabel = isCurrent
        ? l10n.subscriptionCurrentLabel
        : plan.isRecommended
            ? l10n.subscriptionRecommendedBadge
            : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? highlightColor.withOpacity(0.08)
            : plan.isRecommended
                ? highlightColor.withOpacity(0.06)
                : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? highlightColor.withOpacity(0.4)
              : kBrandColor.withOpacity(0.08),
        ),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: kInkColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeLabel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: highlightColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: highlightColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.price,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                plan.period,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kInkColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: plan.features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PlanFeatureRow(
                      label: feature,
                      accent: highlightColor,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isCurrent ? null : onSelect,
              child: Text(
                isCurrent
                    ? l10n.subscriptionCurrentAction
                    : l10n.subscriptionChooseAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanConfirmSheet extends StatelessWidget {
  final _PlanTier plan;

  const _PlanConfirmSheet({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: kSoftShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kInkColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: plan.accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: plan.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.subscriptionConfirmTitle(plan.name),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plan.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: kInkColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.price,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    plan.period,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: kInkColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: plan.features
                    .map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PlanFeatureRow(
                          label: feature,
                          accent: plan.accent,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.subscriptionConfirmSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kInkColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.drawerCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(l10n.subscriptionConfirmAction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanFeatureRow extends StatelessWidget {
  final String label;
  final Color accent;

  const _PlanFeatureRow({
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.16),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 16,
            color: accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kInkColor.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
