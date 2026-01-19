import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_navigation.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../models/seller_stats_models.dart';
import '../services/auth_storage.dart';
import '../services/seller_stats_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/form_section_header.dart';
import '../widgets/section_header.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';

class StatisticsScreen extends StatefulWidget {
  static const String routeName = AppRoutes.statistics;

  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final SellerStatsService _statsService = const SellerStatsService();
  final AuthStorage _authStorage = AuthStorage();

  static const List<String> _rangeKeys = [
    'week',
    'month',
    'quarter',
    'year',
  ];

  int _rangeIndex = 1;
  bool _initialLoadStarted = false;
  bool _isShopStatsLoading = true;
  bool _isStatsLoading = true;
  String? _authToken;
  SellerShopStats? _shopStats;
  SellerStats? _sellerStats;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final l10n = AppLocalizations.of(context);
    final token = await _authStorage.readToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }
    _authToken = token;
    _loadShopStats();
    _loadSellerStats();
  }

  Future<void> _loadShopStats() async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    setState(() {
      _isShopStatsLoading = true;
    });

    try {
      final stats = await _statsService.fetchShopStats(authToken: token);
      if (!mounted) return;
      setState(() {
        _shopStats = stats;
        _isShopStatsLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('Statistics load shop stats failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      setState(() {
        _isShopStatsLoading = false;
      });
      showAppSnackBar(context, _errorMessage(e, l10n.statsLoadFailed));
    }
  }

  Future<void> _loadSellerStats() async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    setState(() {
      _isStatsLoading = true;
    });

    try {
      final range = _rangeKeys[_rangeIndex];
      final stats = await _statsService.fetchSellerStats(
        authToken: token,
        range: range,
      );
      if (!mounted) return;
      setState(() {
        _sellerStats = stats;
        _isStatsLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('Statistics load seller stats failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      setState(() {
        _isStatsLoading = false;
      });
      showAppSnackBar(context, _errorMessage(e, l10n.statsLoadFailed));
    }
  }

  Future<void> _handleUnauthenticated(AppLocalizations l10n) async {
    await _authStorage.clearToken();
    if (!mounted) return;
    showAppSnackBar(context, l10n.storeProfileAuthRequired);
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  bool _isUnauthenticatedError(Object error) {
    return error.toString().contains('Unauthenticated');
  }

  String _errorMessage(Object error, String fallback) {
    final raw = error.toString().trim();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      final message = raw.substring(prefix.length).trim();
      if (message.isNotEmpty) {
        return message;
      }
    }
    if (raw.isNotEmpty && raw != 'Exception') {
      return raw;
    }
    return fallback;
  }

  String _formatCurrency(double value, String currency) {
    final rounded = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
    if (currency.isEmpty) {
      return rounded;
    }
    if (currency.toUpperCase() == 'USD') {
      return '\$$rounded';
    }
    return '$currency $rounded';
  }

  String _formatChange(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  String _currencyAxisLabel(String currency) {
    final trimmed = currency.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.toUpperCase() == 'USD') {
      return '\$';
    }
    return '$trimmed ';
  }

  Color _accentForIndex(int index) {
    const accents = [
      Color(0xFFECE7FF),
      Color(0xFFE7F1FF),
      Color(0xFFFFF1E3),
      Color(0xFFFFE9F0),
      Color(0xFFE6F4F1),
    ];
    return accents[index % accents.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final shopStats = _shopStats;
    final sellerStats = _sellerStats;
    final currency = sellerStats?.currency ?? '';
    final isLoading = _isShopStatsLoading || _isStatsLoading;

    final ranges = [
      l10n.statsRangeWeek,
      l10n.statsRangeMonth,
      l10n.statsRangeQuarter,
      l10n.statsRangeYear,
    ];

    final summary = sellerStats?.summary;
    final metrics = [
      _StatMetric(
        label: l10n.statsMetricRevenue,
        value: _formatCurrency(summary?.revenue.value ?? 0, currency),
        change: _formatChange(summary?.revenue.changePct ?? 0),
        isPositive: (summary?.revenue.changePct ?? 0) >= 0,
        accent: kBrandColor,
        icon: Icons.trending_up,
      ),
      _StatMetric(
        label: l10n.statsMetricOrders,
        value: (summary?.orders.value ?? 0).toStringAsFixed(0),
        change: _formatChange(summary?.orders.changePct ?? 0),
        isPositive: (summary?.orders.changePct ?? 0) >= 0,
        accent: kInfoColor,
        icon: Icons.shopping_cart,
      ),
      _StatMetric(
        label: l10n.statsMetricConversion,
        value: '${(summary?.conversionRate.value ?? 0).toStringAsFixed(1)}%',
        change: _formatChange(summary?.conversionRate.changePct ?? 0),
        isPositive: (summary?.conversionRate.changePct ?? 0) >= 0,
        accent: kSuccessColor,
        icon: Icons.swap_horiz,
      ),
      _StatMetric(
        label: l10n.statsMetricAvgOrder,
        value: _formatCurrency(summary?.avgOrderValue.value ?? 0, currency),
        change: _formatChange(summary?.avgOrderValue.changePct ?? 0),
        isPositive: (summary?.avgOrderValue.changePct ?? 0) >= 0,
        accent: kWarningColor,
        icon: Icons.attach_money,
      ),
      _StatMetric(
        label: l10n.statsMetricCustomers,
        value: (summary?.customers.value ?? 0).toStringAsFixed(0),
        change: _formatChange(summary?.customers.changePct ?? 0),
        isPositive: (summary?.customers.changePct ?? 0) >= 0,
        accent: const Color(0xFF9C27B0),
        icon: Icons.people,
      ),
      _StatMetric(
        label: l10n.statsMetricReturnRate,
        value: '${(summary?.returnRate.value ?? 0).toStringAsFixed(1)}%',
        change: _formatChange(summary?.returnRate.changePct ?? 0),
        isPositive: (summary?.returnRate.changePct ?? 0) >= 0,
        accent: const Color(0xFF4CAF50),
        icon: Icons.refresh,
      ),
    ];

    final trendData = (sellerStats?.trend ?? const <StatsTrendPoint>[])
        .map(
          (point) => _TrendPoint(
            label: point.label,
            revenue: point.revenue,
            orders: point.orders,
            customers: point.customers,
          ),
        )
        .toList();

    final categoryPalette = const [
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
    ];
    final categoryData = (sellerStats?.categories ?? const <StatsCategory>[])
        .asMap()
        .entries
        .map(
          (entry) => _CategoryData(
            entry.value.name,
            entry.value.percentage,
            categoryPalette[entry.key % categoryPalette.length],
          ),
        )
        .toList();

    final monthlyData = (sellerStats?.monthly ?? const <StatsMonthly>[])
        .map(
          (item) => _MonthlyData(
            item.label,
            item.revenue,
            item.orders,
          ),
        )
        .toList();

    final topProducts = (sellerStats?.topProducts ?? const <StatsTopProduct>[])
        .asMap()
        .entries
        .map(
          (entry) => _TopProduct(
            name: entry.value.name,
            category: entry.value.category,
            soldLabel: l10n.statsSoldCount(entry.value.sold),
            revenueLabel: _formatCurrency(entry.value.revenue, currency),
            trend: _formatChange(entry.value.trendPct),
            accent: _accentForIndex(entry.key),
          ),
        )
        .toList();

    final snapshotCards = [
      _SnapshotStat(
        label: l10n.statsShopProductsLabel,
        value: (shopStats?.products.total ?? 0).toString(),
        accent: kBrandColor,
        icon: Icons.inventory_2_outlined,
      ),
      _SnapshotStat(
        label: l10n.statsShopOrdersLabel,
        value: (shopStats?.orders.totalOrders ?? 0).toString(),
        accent: kInfoColor,
        icon: Icons.shopping_cart,
      ),
      _SnapshotStat(
        label: l10n.statsShopFollowersLabel,
        value: (shopStats?.followers ?? 0).toString(),
        accent: kSuccessColor,
        icon: Icons.people_alt_outlined,
      ),
      _SnapshotStat(
        label: l10n.statsShopAvgRatingLabel,
        value: shopStats?.reviewSummary.avgReview ?? '0',
        accent: kWarningColor,
        icon: Icons.star,
      ),
    ];

    final grossSales = shopStats?.orders.grossSales ?? 0;
    final paidSales = shopStats?.orders.paidSales ?? 0;
    final earnings = shopStats?.earnings;

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
              if (isLoading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: kBrandColor,
                  backgroundColor: Colors.transparent,
                ),
              // Header Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: FormSectionHeader(
                  title: l10n.statsTitle,
                  subtitle: l10n.statsSubtitle,
                ),
              ),

              // Time Range Selector
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(ranges.length, (index) {
                      final isSelected = _rangeIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(ranges[index]),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _rangeIndex = index;
                            });
                            _loadSellerStats();
                          },
                          labelStyle: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected ? Colors.white : kInkColor,
                            fontWeight: FontWeight.w600,
                          ),
                          selectedColor: kBrandColor,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? kBrandColor
                                : kBrandColor.withValues(alpha: 0.2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Key Metrics Grid
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: FormSectionHeader(
                  title: l10n.statsShopSnapshotTitle,
                  subtitle: l10n.statsShopSnapshotSubtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                    final itemWidth =
                        (constraints.maxWidth - (crossAxisCount - 1) * 12) /
                            crossAxisCount;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: snapshotCards
                          .map(
                            (item) => SizedBox(
                              width: itemWidth,
                              child: _SnapshotCard(stat: item),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: FormSectionHeader(
                  title: l10n.statsShopSalesTitle,
                  subtitle: l10n.statsShopSalesSubtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatPair(
                          title: l10n.statsShopGrossSalesLabel,
                          value: _formatCurrency(grossSales, currency),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPair(
                          title: l10n.statsShopPaidSalesLabel,
                          value: _formatCurrency(paidSales, currency),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatPair(
                          title: l10n.statsShopEarningsApprovedLabel,
                          value: _formatCurrency(earnings?.approved ?? 0, currency),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPair(
                          title: l10n.statsShopEarningsPendingLabel,
                          value: _formatCurrency(earnings?.pending ?? 0, currency),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPair(
                          title: l10n.statsShopEarningsRefundedLabel,
                          value: _formatCurrency(earnings?.refunded ?? 0, currency),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Key Metrics Grid
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: FormSectionHeader(
                  title: l10n.statsOverviewTitle,
                  subtitle: l10n.statsOverviewSubtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: metrics
                          .map(
                            (metric) => SizedBox(
                              width: itemWidth,
                              child: _EnhancedStatMetricCard(metric: metric),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Revenue Trend Chart
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: FormSectionHeader(
                  title: l10n.statsTrendTitle,
                  subtitle: l10n.statsTrendSubtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _LegendItem(
                            color: kBrandColor,
                            label: l10n.statsMetricRevenue,
                          ),
                          const SizedBox(width: 16),
                          _LegendItem(
                            color: kInfoColor,
                            label: l10n.statsMetricOrders,
                          ),
                          const SizedBox(width: 16),
                          _LegendItem(
                            color: const Color(0xFF9C27B0),
                            label: l10n.statsMetricCustomers,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _RevenueTrendChart(
                          points: trendData,
                          currencyLabel: _currencyAxisLabel(currency),
                          emptyLabel: l10n.statsNoData,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sales by Category Pie Chart
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: SectionHeader(
                  title: l10n.statsCategoryTitle,
                  actionLabel: l10n.statsCategoryAction,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: _CategoryPieChart(
                          data: categoryData,
                          emptyLabel: l10n.statsNoData,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (categoryData.isEmpty)
                        Text(
                          l10n.statsNoData,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: kInkColor.withValues(alpha: 0.6),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: categoryData.map((category) {
                            return _CategoryLegendItem(
                              color: category.color,
                              label: category.name,
                              percentage: category.percentage,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Monthly Performance Bar Chart
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: SectionHeader(
                  title: l10n.statsMonthlyTitle,
                  actionLabel: l10n.statsMonthlyAction,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: SizedBox(
                    height: 250,
                    child: _MonthlyPerformanceChart(
                      data: monthlyData,
                      currencyLabel: _currencyAxisLabel(currency),
                      emptyLabel: l10n.statsNoData,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Top Products Section
              SectionHeader(
                title: l10n.statsTopProductsTitle,
                actionLabel: l10n.homeViewAllAction,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: topProducts.isEmpty
                      ? Text(
                          l10n.statsNoData,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: kInkColor.withValues(alpha: 0.6),
                          ),
                        )
                      : Column(
                          children: List.generate(topProducts.length, (index) {
                            final product = topProducts[index];
                            return Column(
                              children: [
                                _EnhancedTopProductTile(product: product),
                                if (index != topProducts.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      color: kInkColor.withValues(alpha: 0.1),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SellerBottomBar(
        selectedIndex: 4,
        onTap: (index) => handleNavTap(context, index),
      ),
    );
  }
}

class _StatMetric {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final Color accent;
  final IconData icon;

  const _StatMetric({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.accent,
    required this.icon,
  });
}

class _SnapshotStat {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  const _SnapshotStat({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.stat});

  final _SnapshotStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stat.accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: stat.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              stat.icon,
              color: stat.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: kInkColor,
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

class _StatPair extends StatelessWidget {
  const _StatPair({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: kInkColor,
          ),
        ),
      ],
    );
  }
}

class _EnhancedStatMetricCard extends StatelessWidget {
  const _EnhancedStatMetricCard({required this.metric});

  final _StatMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: metric.accent.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: metric.accent.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: metric.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  metric.icon,
                  color: metric.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  metric.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: kInkColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                metric.isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: metric.isPositive ? kSuccessColor : kWarningColor,
              ),
              const SizedBox(width: 4),
              Text(
                metric.change,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: metric.isPositive ? kSuccessColor : kWarningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryLegendItem extends StatelessWidget {
  const _CategoryLegendItem({
    required this.color,
    required this.label,
    required this.percentage,
  });

  final Color color;
  final String label;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label (${percentage.toStringAsFixed(1)}%)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TrendPoint {
  final String label;
  final double revenue;
  final double orders;
  final double customers;

  const _TrendPoint({
    required this.label,
    required this.revenue,
    required this.orders,
    required this.customers,
  });
}

class _RevenueTrendChart extends StatelessWidget {
  const _RevenueTrendChart({
    required this.points,
    required this.currencyLabel,
    required this.emptyLabel,
  });

  final List<_TrendPoint> points;
  final String currencyLabel;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (points.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    final maxRevenue =
        points.map((p) => p.revenue).fold<double>(0, math.max);
    final maxValue = maxRevenue > 0 ? maxRevenue * 1.2 : 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: kInkColor.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < points.length) {
                  return Text(
                    points[value.toInt()].label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: kInkColor.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1000,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '$currencyLabel${(value / 1000).toStringAsFixed(0)}k',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: points.length.toDouble() - 1,
        minY: 0,
        maxY: maxValue,
        lineBarsData: [
          // Revenue Line
          LineChartBarData(
            spots: points.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.revenue);
            }).toList(),
            isCurved: true,
            color: kBrandColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: kBrandColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: kBrandColor.withValues(alpha: 0.1),
            ),
          ),
          // Orders Line
          LineChartBarData(
            spots: points.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.orders * 30); // Scale orders to match revenue scale
            }).toList(),
            isCurved: true,
            color: kInfoColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: kInfoColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
          // Customers Line
          LineChartBarData(
            spots: points.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.customers * 60); // Scale customers
            }).toList(),
            isCurved: true,
            color: const Color(0xFF9C27B0),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF9C27B0),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart({
    required this.data,
    required this.emptyLabel,
  });

  final List<_CategoryData> data;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    return PieChart(
      PieChartData(
        sections: data.map((category) {
          return PieChartSectionData(
            color: category.color,
            value: category.percentage,
            title: '${category.percentage.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            borderSide: BorderSide(
              color: Colors.white,
              width: 2,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

class _MonthlyPerformanceChart extends StatelessWidget {
  const _MonthlyPerformanceChart({
    required this.data,
    required this.currencyLabel,
    required this.emptyLabel,
  });

  final List<_MonthlyData> data;
  final String currencyLabel;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    final maxRevenue = data.map((d) => d.revenue).fold<double>(0, math.max);
    final maxY = maxRevenue > 0 ? maxRevenue * 1.2 : 1.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()].month,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: kInkColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 5000,
              getTitlesWidget: (value, meta) {
                return Text(
                  '$currencyLabel${(value / 1000).toStringAsFixed(0)}k',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: kInkColor.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.revenue,
                color: kBrandColor,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: item.orders * 30, // Scale orders for visibility
                color: kInfoColor,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TopProduct {
  final String name;
  final String category;
  final String soldLabel;
  final String revenueLabel;
  final String trend;
  final Color accent;

  const _TopProduct({
    required this.name,
    required this.category,
    required this.soldLabel,
    required this.revenueLabel,
    required this.trend,
    required this.accent,
  });
}

class _CategoryData {
  final String name;
  final double percentage;
  final Color color;

  const _CategoryData(this.name, this.percentage, this.color);
}

class _MonthlyData {
  final String month;
  final double revenue;
  final double orders;

  const _MonthlyData(this.month, this.revenue, this.orders);
}

class _EnhancedTopProductTile extends StatelessWidget {
  const _EnhancedTopProductTile({required this.product});

  final _TopProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmedName = product.name.trim();
    final initial = trimmedName.isNotEmpty ? trimmedName[0] : '?';

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: product.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: kInkColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.trend.startsWith('+') ? kSuccessColor.withValues(alpha: 0.1) : kWarningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.trend,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: product.trend.startsWith('+') ? kSuccessColor : kWarningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                product.category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kInkColor.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    product.soldLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: kInkColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    product.revenueLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: kBrandColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
