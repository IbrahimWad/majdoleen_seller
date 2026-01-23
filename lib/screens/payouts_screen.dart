import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_navigation.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../widgets/labeled_switch_row.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';
import '../widgets/section_header.dart';

class PayoutsScreen extends StatefulWidget {
  static const String routeName = AppRoutes.payouts;

  const PayoutsScreen({super.key});

  @override
  State<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {
  int _rangeIndex = 1;
  int _statusIndex = 0;
  bool _autoPayout = true;
  bool _instantPayout = false;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  static const List<String> _ranges = [
    '7 days',
    '30 days',
    '90 days',
    'YTD',
  ];

  static const List<String> _statusFilters = [
    'All',
    'Scheduled',
    'Processing',
    'Paid',
    'On hold',
    'Failed',
  ];

  static const _PayoutMethod _method = _PayoutMethod(
    bankName: 'Riyad Bank',
    account: '**** 2210',
    payoutSpeed: '2 business days',
    fee: '\$0.25 per payout',
  );

  static const List<_PayoutInsight> _insights = [
    _PayoutInsight(
      title: 'Net earnings',
      value: '\$24,580',
      subtitle: 'Last 30 days',
      icon: Icons.stacked_line_chart,
      color: kSuccessColor,
    ),
    _PayoutInsight(
      title: 'Processing',
      value: '\$1,420',
      subtitle: '3 transfers',
      icon: Icons.sync,
      color: kWarningColor,
    ),
    _PayoutInsight(
      title: 'On hold',
      value: '\$320',
      subtitle: '2 disputes',
      icon: Icons.pause_circle_outline,
      color: kDangerColor,
    ),
    _PayoutInsight(
      title: 'Fees',
      value: '\$188',
      subtitle: 'Platform fees',
      icon: Icons.receipt_long,
      color: kInfoColor,
    ),
  ];

  static const List<_PayoutSchedule> _schedule = [
    _PayoutSchedule(
      date: 'Fri, Sep 14',
      amount: '\$1,240.00',
      status: 'Scheduled',
      statusColor: kWarningColor,
    ),
    _PayoutSchedule(
      date: 'Fri, Sep 21',
      amount: '\$980.00',
      status: 'Estimated',
      statusColor: kInfoColor,
    ),
    _PayoutSchedule(
      date: 'Fri, Sep 28',
      amount: '\$1,480.00',
      status: 'Projected',
      statusColor: kBrandColor,
    ),
  ];

  static const List<_PayoutEntry> _payouts = [
    _PayoutEntry(
      id: 'PO-8302',
      date: 'Sep 14, 10:00 AM',
      amount: '\$1,240.00',
      status: 'Scheduled',
      statusColor: kWarningColor,
      method: 'Riyad Bank 2210',
      fee: '\$18.40',
      net: '\$1,221.60',
      reference: 'Weekly payout',
    ),
    _PayoutEntry(
      id: 'PO-8298',
      date: 'Sep 12, 4:32 PM',
      amount: '\$420.00',
      status: 'Processing',
      statusColor: kInfoColor,
      method: 'Wallet balance',
      fee: '\$6.30',
      net: '\$413.70',
      reference: 'Instant payout',
      isInstant: true,
    ),
    _PayoutEntry(
      id: 'PO-8289',
      date: 'Sep 10, 9:15 AM',
      amount: '\$980.00',
      status: 'Paid',
      statusColor: kSuccessColor,
      method: 'Riyad Bank 2210',
      fee: '\$14.70',
      net: '\$965.30',
      reference: 'Weekly payout',
    ),
    _PayoutEntry(
      id: 'PO-8276',
      date: 'Sep 08, 2:20 PM',
      amount: '\$310.00',
      status: 'On hold',
      statusColor: kDangerColor,
      method: 'Riyad Bank 2210',
      fee: '\$0.00',
      net: '\$310.00',
      reference: 'Chargeback review',
    ),
    _PayoutEntry(
      id: 'PO-8261',
      date: 'Sep 06, 11:45 AM',
      amount: '\$640.00',
      status: 'Failed',
      statusColor: kDangerColor,
      method: 'Bank transfer',
      fee: '\$0.00',
      net: '\$640.00',
      reference: 'Account verification',
    ),
  ];

  static const List<_PayoutBarData> _chartWeek = [
    _PayoutBarData(label: 'Mon', value: 0.32),
    _PayoutBarData(label: 'Tue', value: 0.56),
    _PayoutBarData(label: 'Wed', value: 0.42),
    _PayoutBarData(label: 'Thu', value: 0.68),
    _PayoutBarData(label: 'Fri', value: 0.74),
    _PayoutBarData(label: 'Sat', value: 0.48),
    _PayoutBarData(label: 'Sun', value: 0.36),
  ];

  static const List<_PayoutBarData> _chartMonth = [
    _PayoutBarData(label: 'W1', value: 0.44),
    _PayoutBarData(label: 'W2', value: 0.72),
    _PayoutBarData(label: 'W3', value: 0.56),
    _PayoutBarData(label: 'W4', value: 0.68),
    _PayoutBarData(label: 'W5', value: 0.38),
  ];

  static const List<_PayoutBarData> _chartQuarter = [
    _PayoutBarData(label: 'Jul', value: 0.62),
    _PayoutBarData(label: 'Aug', value: 0.54),
    _PayoutBarData(label: 'Sep', value: 0.74),
    _PayoutBarData(label: 'Oct', value: 0.48),
    _PayoutBarData(label: 'Nov', value: 0.66),
    _PayoutBarData(label: 'Dec', value: 0.58),
  ];

  static const List<_PayoutBarData> _chartYear = [
    _PayoutBarData(label: 'Q1', value: 0.62),
    _PayoutBarData(label: 'Q2', value: 0.74),
    _PayoutBarData(label: 'Q3', value: 0.56),
    _PayoutBarData(label: 'Q4', value: 0.68),
  ];

  List<_PayoutEntry> get _filteredPayouts {
    final query = _searchQuery.trim().toLowerCase();

    return _payouts.where((payout) {
      if (query.isNotEmpty) {
        final haystack =
        '${payout.id} ${payout.method} ${payout.reference}'.toLowerCase();
        if (!haystack.contains(query)) {
          return false;
        }
      }

      if (_statusIndex != 0) {
        final filter = _statusFilters[_statusIndex].toLowerCase();
        if (payout.status.toLowerCase() != filter) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<_PayoutBarData> get _chartData {
    switch (_rangeIndex) {
      case 0:
        return _chartWeek;
      case 1:
        return _chartMonth;
      case 2:
        return _chartQuarter;
      case 3:
        return _chartYear;
    }
    return _chartMonth;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payouts = _filteredPayouts;
    final emptyMessage = _searchQuery.isNotEmpty || _statusIndex != 0
        ? 'No payouts match the current filters.'
        : 'No payouts available yet.';

    final kpis = [
      const _PayoutKpi(
        title: 'Net',
        value: '\$18.2k',
        delta: '+6.2%',
        color: kSuccessColor,
      ),
      const _PayoutKpi(
        title: 'Fees',
        value: '\$188',
        delta: '-1.4%',
        color: kWarningColor,
      ),
      const _PayoutKpi(
        title: 'Refunds',
        value: '\$64',
        delta: '-0.8%',
        color: kInfoColor,
      ),
      const _PayoutKpi(
        title: 'Chargebacks',
        value: '\$32',
        delta: '2 cases',
        color: kDangerColor,
      ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: kSurfaceColor,
      appBar: const SellerAppBar(),
      drawer: const SellerDrawer(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: SellerBottomBar.bodyBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kBrandColor, kBrandDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: kSoftShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Available balance',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Verified',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '+8.2% this week',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Updated 10:24 AM',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(
                            child: _PayoutMiniStat(
                              title: 'Next payout',
                              value: 'Fri, 10:00 AM',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _PayoutMiniStat(
                              title: 'Pending',
                              value: '\$1,420.00',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: kBrandColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.account_balance_wallet),
                            label: const Text('Request payout'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text('Statements'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SectionHeader(
                title: 'Payout insights',
                actionLabel: 'View report',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _insights
                          .map(
                            (insight) => SizedBox(
                          width: cardWidth,
                          child: _PayoutInsightCard(insight),
                        ),
                      )
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Payout schedule',
                actionLabel: 'Manage',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Next payout',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kWarningColor.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Scheduled',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: kWarningColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$1,240.00',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Arrives Fri, Sep 14 - 2 business days',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kInkColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: 0.68,
                          minHeight: 8,
                          backgroundColor: kBrandColor.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation(kBrandColor),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: _schedule
                            .map(
                              (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PayoutScheduleRow(item),
                          ),
                        )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Payout method',
                actionLabel: 'Change',
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: kBrandColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.account_balance_outlined,
                              color: kBrandColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _method.bankName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _method.account,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: kInkColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kSuccessColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Primary',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: kSuccessColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _PayoutMethodStat(
                              title: 'Speed',
                              value: _method.payoutSpeed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PayoutMethodStat(
                              title: 'Fee',
                              value: _method.fee,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      LabeledSwitchRow(
                        title: 'Auto payout',
                        subtitle: 'Send balance weekly on Friday',
                        value: _autoPayout,
                        onChanged: (value) {
                          setState(() {
                            _autoPayout = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      LabeledSwitchRow(
                        title: 'Instant payout',
                        subtitle: 'Settle immediately with 1.5% fee',
                        value: _instantPayout,
                        onChanged: (value) {
                          setState(() {
                            _instantPayout = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Payout analytics',
                actionLabel: 'View details',
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_ranges.length, (index) {
                      final isSelected = _rangeIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(_ranges[index]),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _rangeIndex = index;
                            });
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
                                : kBrandColor.withOpacity(0.2),
                          ),
                        ),
                      );
                    }),
                  ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payout volume',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Net payouts in ${_ranges[_rangeIndex].toLowerCase()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kInkColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PayoutBarChart(data: _chartData),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = (constraints.maxWidth - 12) / 2;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: kpis
                                .map(
                                  (kpi) => SizedBox(
                                width: itemWidth,
                                child: _PayoutKpiCard(kpi),
                              ),
                            )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Payout activity',
                actionLabel: 'Export',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by payout ID or reference',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_statusFilters.length, (index) {
                      final isSelected = _statusIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(_statusFilters[index]),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _statusIndex = index;
                            });
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
                                : kBrandColor.withOpacity(0.2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Payouts (${payouts.length})',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      'Sort: Latest',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: kBrandColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (payouts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kBrandColor.withOpacity(0.1)),
                    ),
                    child: Text(
                      emptyMessage,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: payouts
                        .map(
                          (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PayoutActivityCard(entry),
                      ),
                    )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Material(
        type: MaterialType.transparency,
        child: SellerBottomBar(
          selectedIndex: 3,
          onTap: (index) => handleNavTap(context, index),
        ),
      ),
    );
  }
}

class _PayoutMethod {
  final String bankName;
  final String account;
  final String payoutSpeed;
  final String fee;

  const _PayoutMethod({
    required this.bankName,
    required this.account,
    required this.payoutSpeed,
    required this.fee,
  });
}

class _PayoutInsight {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PayoutInsight({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _PayoutInsightCard extends StatelessWidget {
  final _PayoutInsight insight;

  const _PayoutInsightCard(this.insight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: insight.color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(insight.icon, color: insight.color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            insight.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kInkColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: kInkColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            insight.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kInkColor.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutSchedule {
  final String date;
  final String amount;
  final String status;
  final Color statusColor;

  const _PayoutSchedule({
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
  });
}

class _PayoutScheduleRow extends StatelessWidget {
  final _PayoutSchedule schedule;

  const _PayoutScheduleRow(this.schedule);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: schedule.statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_today_outlined,
            color: schedule.statusColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.date,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                schedule.amount,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kInkColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: schedule.statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            schedule.status,
            style: theme.textTheme.labelSmall?.copyWith(
              color: schedule.statusColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PayoutMethodStat extends StatelessWidget {
  final String title;
  final String value;

  const _PayoutMethodStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kInkColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutMiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _PayoutMiniStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
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

class _PayoutBarData {
  final String label;
  final double value;

  const _PayoutBarData({
    required this.label,
    required this.value,
  });
}

class _PayoutBarChart extends StatelessWidget {
  final List<_PayoutBarData> data;

  const _PayoutBarChart({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const maxBarHeight = 140.0;

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data
            .map(
              (bar) => Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: maxBarHeight * bar.value,
                  width: 16,
                  decoration: BoxDecoration(
                    color: kBrandColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bar.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: kInkColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _PayoutKpi {
  final String title;
  final String value;
  final String delta;
  final Color color;

  const _PayoutKpi({
    required this.title,
    required this.value,
    required this.delta,
    required this.color,
  });
}

class _PayoutKpiCard extends StatelessWidget {
  final _PayoutKpi kpi;

  const _PayoutKpiCard(this.kpi);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kpi.color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kpi.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kInkColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            kpi.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: kInkColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            kpi.delta,
            style: theme.textTheme.labelSmall?.copyWith(
              color: kpi.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutEntry {
  final String id;
  final String date;
  final String amount;
  final String status;
  final Color statusColor;
  final String method;
  final String fee;
  final String net;
  final String reference;
  final bool isInstant;

  const _PayoutEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.method,
    required this.fee,
    required this.net,
    required this.reference,
    this.isInstant = false,
  });
}

class _PayoutActivityCard extends StatelessWidget {
  final _PayoutEntry entry;

  const _PayoutActivityCard(this.entry);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Text(
                  entry.id,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (entry.isInstant)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kInfoColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Instant',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: kInfoColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: entry.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  entry.status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: entry.statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.date,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kInkColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _PayoutMeta(
                icon: Icons.account_balance_outlined,
                text: entry.method,
              ),
              _PayoutMeta(
                icon: Icons.receipt_long_outlined,
                text: 'Fee ${entry.fee}',
              ),
              _PayoutMeta(
                icon: Icons.check_circle_outline,
                text: 'Net ${entry.net}',
              ),
              _PayoutMeta(
                icon: Icons.tag_outlined,
                text: entry.reference,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayoutMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PayoutMeta({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: kInkColor.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withOpacity(0.65),
          ),
        ),
      ],
    );
  }
}
