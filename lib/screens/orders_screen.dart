import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_navigation.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../models/seller_order_models.dart';
import '../services/auth_storage.dart';
import '../services/seller_orders_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';
import '../widgets/summary_card.dart';

const Map<String, int> _deliveryStatusCodes = {
  'pending': 0,
  'processing': 1,
  'ready_to_ship': 2,
  'shipped': 3,
  'delivered': 4,
  'cancelled': 5,
};

const Map<String, int> _paymentStatusCodes = {
  'unpaid': 0,
  'paid': 1,
};

class OrdersScreen extends StatefulWidget {
  static const String routeName = AppRoutes.orders;

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SellerOrdersService _ordersService = const SellerOrdersService();
  final AuthStorage _authStorage = AuthStorage();

  static const Duration _requestTimeout = Duration(seconds: 20);

  Timer? _searchDebounce;
  String _searchQuery = '';

  int _statusIndex = 0;
  int _paymentIndex = 0;

  List<SellerOrderSummary> _orders = [];
  SellerOrderListMeta? _meta;
  SellerOrderCounters? _counters;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _authToken;
  bool _initialLoadStarted = false;

  static const List<String> _statusKeys = [
    'all',
    'pending',
    'processing',
    'ready_to_ship',
    'shipped',
    'delivered',
    'cancelled',
  ];

  static const List<String> _paymentFilterKeys = [
    'all',
    'paid',
    'unpaid',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;
    _loadInitial();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_isLoadingMore || _isLoading) return;
    if (!_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadOrders(reset: false);
    }
  }

  Future<void> _loadInitial() async {
    final l10n = AppLocalizations.of(context);
    final token = await _authStorage.readToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }
    setState(() {
      _authToken = token;
    });
    await Future.wait([
      _loadCounters(),
      _loadOrders(reset: true),
    ]);
  }

  Future<void> _loadCounters() async {
    final token = _authToken;
    if (token == null || token.isEmpty) {
      final l10n = AppLocalizations.of(context);
      await _handleUnauthenticated(l10n);
      return;
    }

    try {
      final counters = await _ordersService
          .fetchCounters(authToken: token)
          .timeout(_requestTimeout);
      if (!mounted) return;
      setState(() {
        _counters = counters;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('OrdersScreen loadCounters failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      showAppSnackBar(context, _errorMessage(e, l10n.ordersCountersFailed));
    }
  }

  Future<void> _loadOrders({required bool reset}) async {
    final token = _authToken;
    if (token == null || token.isEmpty) {
      final l10n = AppLocalizations.of(context);
      await _handleUnauthenticated(l10n);
      return;
    }

    if (reset) {
      setState(() {
        _isLoading = true;
        _meta = null;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final nextPage = reset ? 1 : (_meta?.currentPage ?? 1) + 1;
    if (!reset && _meta != null && nextPage > (_meta?.lastPage ?? 1)) {
      setState(() {
        _isLoadingMore = false;
      });
      return;
    }

    try {
      final response = await _ordersService
          .fetchOrders(
            authToken: token,
            deliveryStatus: _deliveryStatusFilterParam(),
            paymentStatus: _paymentStatusFilterParam(),
            orderCode: _searchQuery,
            perPage: (_meta?.perPage ?? 10).toString(),
            page: nextPage,
          )
          .timeout(_requestTimeout);
      if (!mounted) return;
      setState(() {
        _meta = response.meta ?? _meta;
        if (reset) {
          _orders = response.orders;
        } else {
          _orders = [..._orders, ...response.orders];
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('OrdersScreen loadOrders failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      showAppSnackBar(context, _errorMessage(e, l10n.ordersLoadFailed));
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadCounters(),
      _loadOrders(reset: true),
    ]);
  }

  bool get _hasMore {
    final meta = _meta;
    if (meta == null) return false;
    return meta.currentPage < meta.lastPage;
  }

  String? _deliveryStatusFilterParam() {
    final key = _statusKeys[_statusIndex];
    if (key == 'all') return null;
    final code = _deliveryStatusCodes[key];
    return code?.toString() ?? key;
  }

  String? _paymentStatusFilterParam() {
    final key = _paymentFilterKeys[_paymentIndex];
    if (key == 'all') return null;
    final code = _paymentStatusCodes[key];
    return code?.toString() ?? key;
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value;
      });
      _loadOrders(reset: true);
    });
  }

  void _openFilters() {
    final l10n = AppLocalizations.of(context);
    var tempPayment = _paymentIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.only(top: 60),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.ordersFilterTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: kInkColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFilterGroup(
                        title: l10n.ordersFilterPaymentTitle,
                        options: _paymentFilterKeys
                            .map((key) => _paymentFilterLabel(l10n, key))
                            .toList(),
                        selectedIndex: tempPayment,
                        onSelected: (index) {
                          setModalState(() {
                            tempPayment = index;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempPayment = 0;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: kBrandColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(l10n.ordersFilterClearAction),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                setState(() {
                                  _paymentIndex = tempPayment;
                                });
                                Navigator.of(context).pop();
                                _loadOrders(reset: true);
                              },
                              child: Text(l10n.ordersFilterApplyAction),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final orders = _orders;
    final totalCount = _meta?.total ?? orders.length;
    final activeFilterCount = _paymentIndex == 0 ? 0 : 1;
    final emptyMessage = _searchQuery.isNotEmpty ||
            _paymentIndex != 0 ||
            _statusIndex != 0
        ? l10n.ordersEmptyFiltered
        : l10n.ordersEmpty;

    final counters = _counters;
    final summaries = [
      SummaryItem(
        label: _statusLabel(l10n, 'pending'),
        value: counters?.countFor('pending') ?? 0,
        color: kInfoColor,
      ),
      SummaryItem(
        label: _statusLabel(l10n, 'processing'),
        value: counters?.countFor('processing') ?? 0,
        color: kWarningColor,
      ),
      SummaryItem(
        label: _statusLabel(l10n, 'ready_to_ship'),
        value: counters?.countFor('ready_to_ship') ?? 0,
        color: kSuccessColor,
      ),
      SummaryItem(
        label: _statusLabel(l10n, 'delivered'),
        value: counters?.countFor('delivered') ?? 0,
        color: kBrandColor,
      ),
    ];

    return Scaffold(
      appBar: const SellerAppBar(),
      drawer: const SellerDrawer(),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: kBrandColor,
                    backgroundColor: Colors.transparent,
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: l10n.ordersSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: SizedBox(
                        width: _searchQuery.isEmpty ? 48 : 96,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  _loadOrders(reset: true);
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                            IconButton(
                              onPressed: _openFilters,
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.tune_rounded),
                                if (activeFilterCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kBrandColor,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        activeFilterCount.toString(),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_statusKeys.length, (index) {
                        final isSelected = _statusIndex == index;
                        final label = _statusLabel(l10n, _statusKeys[index]);
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _statusIndex = index;
                              });
                              _loadOrders(reset: true);
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        summaries.map((item) => SummaryCard(item: item)).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.ordersListTitle(totalCount),
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        l10n.ordersSortLatest,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kBrandColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (orders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: kBrandColor.withValues(alpha: 0.1),
                        ),
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
                      children: [
                        ...orders.map(
                          (order) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OrderDetailCard(
                              order,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        _OrderDetailsScreen(order: order),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (_isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SellerBottomBar(
        selectedIndex: 0,
        onTap: (index) => handleNavTap(context, index),
      ),
    );
  }
}

String _statusLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'all':
      return l10n.ordersFilterAll;
    case 'pending':
      return l10n.ordersStatusPending;
    case 'processing':
      return l10n.ordersStatusProcessing;
    case 'ready_to_ship':
      return l10n.ordersStatusReadyToShip;
    case 'shipped':
      return l10n.ordersStatusShipped;
    case 'delivered':
      return l10n.ordersStatusDelivered;
    case 'cancelled':
      return l10n.ordersStatusCancelled;
  }
  return key;
}

Color _statusColorForKey(String key) {
  switch (key) {
    case 'pending':
      return kInfoColor;
    case 'processing':
      return kWarningColor;
    case 'ready_to_ship':
      return kSuccessColor;
    case 'shipped':
      return kBrandColor;
    case 'delivered':
      return kSuccessColor;
    case 'cancelled':
      return kDangerColor;
  }
  return kBrandColor;
}

String _paymentFilterLabel(AppLocalizations l10n, String key) {
  if (key == 'all') {
    return l10n.ordersFilterAll;
  }
  return _paymentStatusLabel(l10n, key);
}

String _paymentStatusLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'paid':
      return l10n.ordersPaymentStatusPaid;
    case 'unpaid':
      return l10n.ordersPaymentStatusUnpaid;
  }
  return key;
}

String _deliveryStatusKeyFromLabel(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized.contains('pending')) {
    return 'pending';
  }
  if (normalized.contains('processing')) {
    return 'processing';
  }
  if (normalized.contains('ready')) {
    return 'ready_to_ship';
  }
  if (normalized.contains('shipped')) {
    return 'shipped';
  }
  if (normalized.contains('delivered')) {
    return 'delivered';
  }
  if (normalized.contains('cancel')) {
    return 'cancelled';
  }
  return 'pending';
}

String _paymentStatusKeyFromLabel(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized.contains('unpaid')) {
    return 'unpaid';
  }
  if (normalized.contains('paid')) {
    return 'paid';
  }
  return 'unpaid';
}

String _deliveryStatusKeyFromCode(int? code) {
  if (code == null) return 'pending';
  for (final entry in _deliveryStatusCodes.entries) {
    if (entry.value == code) {
      return entry.key;
    }
  }
  return 'pending';
}

String _paymentStatusKeyFromCode(int? code) {
  if (code == null) return 'unpaid';
  for (final entry in _paymentStatusCodes.entries) {
    if (entry.value == code) {
      return entry.key;
    }
  }
  return 'unpaid';
}

String _formatMoney(double value) {
  return '\$${value.toStringAsFixed(2)}';
}

String _formatOrderDate(SellerOrderSummary order) {
  return order.orderDate ?? order.createdAt ?? '';
}

String _resolveDeliveryLabel(AppLocalizations l10n, SellerOrderSummary order) {
  if (order.deliveryStatusLabel.isNotEmpty) {
    return order.deliveryStatusLabel;
  }
  final key = order.deliveryStatus != null
      ? _deliveryStatusKeyFromCode(order.deliveryStatus)
      : _deliveryStatusKeyFromLabel(order.deliveryStatusLabel);
  return _statusLabel(l10n, key);
}

String _resolvePaymentLabel(AppLocalizations l10n, SellerOrderSummary order) {
  if (order.paymentStatusLabel.isNotEmpty) {
    return order.paymentStatusLabel;
  }
  final key = order.paymentStatus != null
      ? _paymentStatusKeyFromCode(order.paymentStatus)
      : _paymentStatusKeyFromLabel(order.paymentStatusLabel);
  return _paymentStatusLabel(l10n, key);
}

class _OrderDetailsScreen extends StatefulWidget {
  final SellerOrderSummary order;

  const _OrderDetailsScreen({required this.order});

  @override
  State<_OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<_OrderDetailsScreen> {
  final SellerOrdersService _ordersService = const SellerOrdersService();
  final AuthStorage _authStorage = AuthStorage();
  final TextEditingController _noteController = TextEditingController();

  bool _initialLoadStarted = false;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _authToken;
  SellerOrderDetails? _details;
  String _deliveryStatusKey = 'pending';
  String _paymentStatusKey = 'unpaid';

  static const List<String> _deliveryStatusKeys = [
    'pending',
    'processing',
    'ready_to_ship',
    'shipped',
    'delivered',
    'cancelled',
  ];

  static const List<String> _paymentStatusKeys = [
    'paid',
    'unpaid',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;
    _loadInitial();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
    await _loadDetails();
  }

  Future<void> _loadDetails() async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final details = await _ordersService
          .fetchOrderDetails(
            authToken: token,
            orderId: widget.order.id,
          )
          .timeout(const Duration(seconds: 20));
      if (!mounted) return;
      final deliveryCode = details.deliveryStatus ??
          (details.products.isNotEmpty
              ? details.products.first.deliveryStatus
              : null);
      final paymentCode = details.paymentStatus ??
          (details.products.isNotEmpty
              ? details.products.first.paymentStatus
              : null);
      setState(() {
        _details = details;
        _deliveryStatusKey = _deliveryStatusKeyFromCode(deliveryCode);
        _paymentStatusKey = _paymentStatusKeyFromCode(paymentCode);
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('OrderDetails load failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
      showAppSnackBar(context, _errorMessage(e, l10n.ordersDetailsLoadFailed));
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

  Future<void> _acceptOrder() async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }
    setState(() {
      _isUpdating = true;
    });
    try {
      await _ordersService.acceptOrder(
        authToken: token,
        orderId: widget.order.id,
      );
      if (!mounted) return;
      showAppSnackBar(context, l10n.ordersAcceptSuccess);
      await _loadDetails();
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('OrderDetails accept failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      showAppSnackBar(context, _errorMessage(e, l10n.ordersAcceptFailed));
    } finally {
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _confirmCancel() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kDangerColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.block_outlined,
                      color: kDangerColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.ordersDetailsRejectTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: kInkColor,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.ordersDetailsRejectMessage,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: kInkColor.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: kDangerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        l10n.ordersDetailsRejectCancel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: kDangerColor,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: kDangerColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.ordersDetailsRejectConfirm,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await _cancelOrder();
  }

  Future<void> _cancelOrder() async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }
    setState(() {
      _isUpdating = true;
    });
    try {
      await _ordersService.cancelOrder(
        authToken: token,
        orderId: widget.order.id,
      );
      if (!mounted) return;
      showAppSnackBar(context, l10n.ordersCancelSuccess);
      await _loadDetails();
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('OrderDetails cancel failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      showAppSnackBar(context, _errorMessage(e, l10n.ordersCancelFailed));
    } finally {
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _updateStatus() async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    if (_deliveryStatusKey == 'delivered' &&
        _paymentStatusKey == 'unpaid') {
      showAppSnackBar(context, l10n.ordersStatusInvalidDeliveredUnpaid);
      return;
    }

    final deliveryCode = _deliveryStatusCodes[_deliveryStatusKey];
    final paymentCode = _paymentStatusCodes[_paymentStatusKey];

    if (deliveryCode == null || paymentCode == null) {
      showAppSnackBar(context, l10n.ordersStatusUpdateFailed);
      return;
    }

    final details = _details;
    if (details == null || details.products.isEmpty) {
      showAppSnackBar(context, l10n.ordersStatusUpdateFailed);
      return;
    }

    final productIds = details.products
        .map((item) => item.id)
        .where((id) => id > 0)
        .toList();
    if (productIds.isEmpty) {
      showAppSnackBar(context, l10n.ordersStatusUpdateFailed);
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _ordersService.updateOrderStatus(
        authToken: token,
        orderId: widget.order.id,
        productIds: productIds,
        deliveryStatus: deliveryCode,
        paymentStatus: paymentCode,
        comment: _noteController.text,
      );
      if (!mounted) return;
      showAppSnackBar(context, l10n.ordersDetailsSavedMessage);
      await _loadDetails();
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('OrderDetails update failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      showAppSnackBar(context, _errorMessage(e, l10n.ordersStatusUpdateFailed));
    } finally {
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final details = _details;

    final deliveryLabel = details?.deliveryStatusLabel.isNotEmpty == true
        ? details!.deliveryStatusLabel
        : _statusLabel(l10n, _deliveryStatusKey);
    final paymentLabel = details?.paymentStatusLabel.isNotEmpty == true
        ? details!.paymentStatusLabel
        : _paymentStatusLabel(l10n, _paymentStatusKey);

    final customerName =
        details?.customer?.name ?? widget.order.customer?.name ?? '';
    final itemsCount = details?.products.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        ) ??
        widget.order.totalItems;
    final totalPayable = details?.totals.totalPayable ?? widget.order.sellerAmount;
    final orderDate = details?.orderDate ?? _formatOrderDate(widget.order);
    final shippingAddress =
        details == null ? '' : _formatAddress(details.shippingDetails);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ordersDetailsTitle),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading || _isUpdating)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: kBrandColor,
                  backgroundColor: Colors.transparent,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
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
                          Expanded(
                            child: Text(
                              widget.order.orderCode.isNotEmpty
                                  ? widget.order.orderCode
                                  : '#${widget.order.id}',
                              style: theme.textTheme.titleMedium?.copyWith(
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
                              color: _statusColorForKey(_deliveryStatusKey)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              deliveryLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _statusColorForKey(_deliveryStatusKey),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        customerName.isNotEmpty
                            ? customerName
                            : l10n.ordersUnknownCustomer,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.ordersItemsLine(itemsCount, _formatMoney(totalPayable)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kInkColor.withValues(alpha: 0.6),
                        ),
                      ),
                      if (details?.sellerCanAccept == true) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _isUpdating ? null : _acceptOrder,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(l10n.ordersAcceptAction),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.ordersDetailsSummaryTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
                    children: [
                      _OrderInfoRow(
                        label: l10n.ordersDetailsCustomerLabel,
                        value: customerName.isNotEmpty
                            ? customerName
                            : l10n.ordersUnknownCustomer,
                      ),
                      const SizedBox(height: 8),
                      _OrderInfoRow(
                        label: l10n.ordersDetailsItemsLabel,
                        value: l10n.ordersItemsCount(itemsCount),
                      ),
                      const SizedBox(height: 8),
                      _OrderInfoRow(
                        label: l10n.ordersDetailsTotalLabel,
                        value: _formatMoney(totalPayable),
                      ),
                      const SizedBox(height: 8),
                      _OrderInfoRow(
                        label: l10n.ordersDetailsPaymentLabel,
                        value: paymentLabel,
                      ),
                      const SizedBox(height: 8),
                      _OrderInfoRow(
                        label: l10n.ordersDetailsDeliveryLabel,
                        value: deliveryLabel,
                      ),
                      if (shippingAddress.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _OrderInfoRow(
                          label: l10n.ordersDetailsLocationLabel,
                          value: shippingAddress,
                        ),
                      ],
                      if (orderDate.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _OrderInfoRow(
                          label: l10n.ordersDetailsPlacedLabel,
                          value: orderDate,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.ordersDetailsItemsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            for (int i = 0; i < (details?.products.length ?? 0); i++) ...[
                              _OrderItemRow(details!.products[i]),
                              if (i != (details.products.length - 1))
                                const Divider(height: 24),
                            ],
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.ordersDetailsStatusTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.ordersDetailsDeliveryLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: kInkColor.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _deliveryStatusKeys.map((key) {
                          final isSelected = _deliveryStatusKey == key;
                          return ChoiceChip(
                            label: Text(_statusLabel(l10n, key)),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _deliveryStatusKey = key;
                              });
                            },
                            selectedColor: kBrandColor,
                            backgroundColor: Colors.white,
                            labelStyle: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected ? Colors.white : kInkColor,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? kBrandColor
                                  : kBrandColor.withValues(alpha: 0.2),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.ordersDetailsPaymentLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: kInkColor.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _paymentStatusKeys.map((key) {
                          final isSelected = _paymentStatusKey == key;
                          return ChoiceChip(
                            label: Text(_paymentStatusLabel(l10n, key)),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _paymentStatusKey = key;
                              });
                            },
                            selectedColor: kBrandColor,
                            backgroundColor: Colors.white,
                            labelStyle: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected ? Colors.white : kInkColor,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? kBrandColor
                                  : kBrandColor.withValues(alpha: 0.2),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.ordersDetailsNotesTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
                  child: TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.ordersDetailsNotesTitle,
                      hintText: l10n.ordersDetailsNotesHint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: (details?.sellerCanCancel ?? false) && !_isUpdating
                      ? _confirmCancel
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: kDangerColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    l10n.ordersDetailsRejectAction,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: kDangerColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isUpdating ? null : _updateStatus,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.ordersDetailsSaveAction,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderDetailCard extends StatelessWidget {
  final SellerOrderSummary order;
  final VoidCallback? onTap;

  const _OrderDetailCard(this.order, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final deliveryLabel = _resolveDeliveryLabel(l10n, order);
    final paymentLabel = _resolvePaymentLabel(l10n, order);
    final statusKey = order.deliveryStatusLabel.isNotEmpty
        ? _deliveryStatusKeyFromLabel(order.deliveryStatusLabel)
        : _deliveryStatusKeyFromCode(order.deliveryStatus);
    final statusColor = _statusColorForKey(statusKey);
    final orderDate = _formatOrderDate(order);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.15),
            ),
            boxShadow: kSoftShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderCode.isNotEmpty
                          ? order.orderCode
                          : '#${order.id}',
                      style: theme.textTheme.bodyMedium?.copyWith(
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
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      deliveryLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.customer?.name ?? l10n.ordersUnknownCustomer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.ordersItemsLine(
                  order.totalItems,
                  _formatMoney(order.sellerAmount),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kInkColor.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _OrderMeta(
                    icon: Icons.local_shipping_outlined,
                    text: deliveryLabel,
                  ),
                  _OrderMeta(
                    icon: Icons.payments_outlined,
                    text: paymentLabel,
                  ),
                ],
              ),
              if (orderDate.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  orderDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final SellerOrderProduct item;

  const _OrderItemRow(this.item);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final deliveryStatus = item.deliveryStatusLabel.isNotEmpty
        ? item.deliveryStatusLabel
        : _statusLabel(
            l10n,
            _deliveryStatusKeyFromCode(item.deliveryStatus),
          );
    final paymentStatus = item.paymentStatusLabel.isNotEmpty
        ? item.paymentStatusLabel
        : _paymentStatusLabel(
            l10n,
            _paymentStatusKeyFromCode(item.paymentStatus),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              _formatMoney(item.lineTotal),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              l10n.ordersDetailsItemQuantity(item.quantity),
              style: theme.textTheme.bodySmall?.copyWith(
                color: kInkColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              l10n.ordersDetailsItemUnitPrice(_formatMoney(item.unitPrice)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: kInkColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (deliveryStatus.isNotEmpty || paymentStatus.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (deliveryStatus.isNotEmpty)
                _StatusChip(text: deliveryStatus),
              if (paymentStatus.isNotEmpty)
                _StatusChip(text: paymentStatus),
              if (item.returnStatusLabel.isNotEmpty)
                _StatusChip(text: item.returnStatusLabel),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;

  const _StatusChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kBrandColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: kBrandColor.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: kInkColor.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrderMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OrderMeta({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: kInkColor.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _OrderInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kInkColor.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kInkColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatAddress(Map<String, dynamic> details) {
  final parts = <String>[];
  for (final key in [
    'address',
    'street',
    'city',
    'state',
    'country',
    'zip',
  ]) {
    final value = details[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) {
      parts.add(text);
    }
  }
  return parts.join(', ');
}

Widget _buildFilterGroup({
  required String title,
  required List<String> options,
  required int selectedIndex,
  required ValueChanged<int> onSelected,
}) {
  return _FilterGroup(
    title: title,
    options: options,
    selectedIndex: selectedIndex,
    onSelected: onSelected,
  );
}

class _FilterGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FilterGroup({
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(options.length, (index) {
            final isSelected = selectedIndex == index;
            return ChoiceChip(
              label: Text(options[index]),
              selected: isSelected,
              onSelected: (_) => onSelected(index),
              selectedColor: kBrandColor,
              backgroundColor: Colors.white,
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : kInkColor,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color:
                    isSelected ? kBrandColor : kBrandColor.withValues(alpha: 0.2),
              ),
            );
          }),
        ),
      ],
    );
  }
}
