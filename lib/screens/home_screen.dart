import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_navigation.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../widgets/section_header.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = AppRoutes.home;

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final metrics = [
      _Metric(
        title: l10n.homeTodaySalesTitle,
        value: '\$2,450',
        subtitle: l10n.homeTodaySalesSubtitle,
        icon: Icons.trending_up,
        accent: kSuccessColor,
      ),
      _Metric(
        title: l10n.homePendingOrdersTitle,
        value: '6',
        subtitle: l10n.homePendingOrdersSubtitle,
        icon: Icons.inventory_2_outlined,
        accent: kWarningColor,
      ),
      _Metric(
        title: l10n.homeAvailableBalanceTitle,
        value: '\$8,420',
        subtitle: l10n.homeAvailableBalanceSubtitle,
        icon: Icons.account_balance_wallet_outlined,
        accent: kInfoColor,
      ),
      _Metric(
        title: l10n.homeStoreRatingTitle,
        value: '4.8',
        subtitle: l10n.homeStoreRatingSubtitle,
        icon: Icons.star_outline,
        accent: kBrandColor,
      ),
    ];

    final actions = [
      _QuickAction(
        title: l10n.homeQuickActionAddProduct,
        icon: Icons.add_box_outlined,
        color: kBrandColor,
      ),
      _QuickAction(
        title: l10n.homeQuickActionCreateOffer,
        icon: Icons.local_offer_outlined,
        color: kInfoColor,
      ),
      _QuickAction(
        title: l10n.homeQuickActionMessageBuyers,
        icon: Icons.chat_bubble_outline,
        color: kSuccessColor,
      ),
      _QuickAction(
        title: l10n.homeQuickActionRequestPayout,
        icon: Icons.account_balance_wallet_outlined,
        color: kWarningColor,
      ),
    ];

    final orders = [
      _OrderInfo(
        id: 'MS-1042',
        customer: 'Lina B.',
        items: 3,
        total: '\$86.50',
        status: l10n.homeOrderStatusPackaging,
        statusColor: kWarningColor,
        time: l10n.homeOrderTime12MinAgo,
      ),
      _OrderInfo(
        id: 'MS-1041',
        customer: 'Hadi R.',
        items: 1,
        total: '\$32.00',
        status: l10n.homeOrderStatusReadyForPickup,
        statusColor: kSuccessColor,
        time: l10n.homeOrderTime28MinAgo,
      ),
      _OrderInfo(
        id: 'MS-1039',
        customer: 'Rana H.',
        items: 5,
        total: '\$140.00',
        status: l10n.homeOrderStatusNewOrder,
        statusColor: kInfoColor,
        time: l10n.homeOrderTime1HrAgo,
      ),
    ];

    final inventory = [
      _InventoryAlert(
        name: 'Rose Oil 50ml',
        detail: l10n.homeInventoryOnly6Left,
        color: kWarningColor,
      ),
      _InventoryAlert(
        name: 'Lavender Mist',
        detail: l10n.homeInventoryLowStock12Left,
        color: kInfoColor,
      ),
      _InventoryAlert(
        name: 'Jasmine Set',
        detail: l10n.homeInventoryRestockSoon,
        color: kBrandColor,
      ),
    ];

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
              _HomeHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Text(
                  l10n.homeTodayOverviewTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      metrics.map((metric) => _MetricCard(metric)).toList(),
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: l10n.homeQuickActionsTitle,
                actionLabel: l10n.homeQuickActionsAction,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tileWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: actions
                          .map(
                            (action) => SizedBox(
                              width: tileWidth,
                              child: _QuickActionTile(action),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: l10n.homeNewOrdersTitle,
                actionLabel: l10n.homeViewAllAction,
                onActionTap: () => handleNavTap(context, 0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: orders
                      .map(
                        (order) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OrderCard(order),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              SectionHeader(
                title: l10n.homeInventoryAlertsTitle,
                actionLabel: l10n.homeRestockAction,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: inventory
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _InventoryCard(item),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SellerBottomBar(
        selectedIndex: 2,
        onTap: (index) => handleNavTap(context, index),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBrandColor, kBrandDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeAvailableBalanceTitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$12,980.50',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.homeBalanceChangeThisWeek,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  title: l10n.homeNextPayoutLabel,
                  value: l10n.homeNextPayoutValue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeaderStat(
                  title: l10n.homeOrdersTodayLabel,
                  value: l10n.homeOrdersTodayValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String title;
  final String value;

  const _HeaderStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _Metric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

class _MetricCard extends StatelessWidget {
  final _Metric metric;

  const _MetricCard(this.metric);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final effectiveHeight = maxHeight / textScaleFactor;
        final t =
            ((effectiveHeight - 120) / 30).clamp(0.0, 1.0).toDouble();
        double lerp(double a, double b) => a + (b - a) * t;
        final padding = lerp(10.0, 14.0);
        final iconBoxSize = lerp(28.0, 34.0);
        final iconSize = lerp(18.0, 20.0);
        final gapLarge = lerp(4.0, 10.0);
        final gapMedium = lerp(2.0, 4.0);
        final gapSmall = lerp(0.0, 2.0);

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: kSoftShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: metric.accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(metric.icon, color: metric.accent, size: iconSize),
              ),
              SizedBox(height: gapLarge),
              Text(
                metric.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kInkColor.withOpacity(0.6),
                ),
              ),
              SizedBox(height: gapMedium),
              Text(
                metric.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: gapSmall),
              Text(
                metric.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kInkColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;

  const _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionTile(this.action);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBrandColor.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(action.icon, color: action.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderInfo {
  final String id;
  final String customer;
  final int items;
  final String total;
  final String status;
  final Color statusColor;
  final String time;

  const _OrderInfo({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.status,
    required this.statusColor,
    required this.time,
  });
}

class _OrderCard extends StatelessWidget {
  final _OrderInfo order;

  const _OrderCard(this.order);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: order.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                order.customer.substring(0, 1),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: order.statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.id} - ${order.customer}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.homeOrderItemsLine(order.items, order.total),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: order.statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                order.time,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kInkColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventoryAlert {
  final String name;
  final String detail;
  final Color color;

  const _InventoryAlert({
    required this.name,
    required this.detail,
    required this.color,
  });
}

class _InventoryCard extends StatelessWidget {
  final _InventoryAlert item;

  const _InventoryCard(this.item);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: item.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            l10n.homeRestockAction,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kBrandColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
