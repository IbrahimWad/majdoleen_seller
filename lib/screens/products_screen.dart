import 'dart:async';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_navigation.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../models/seller_product_models.dart';
import '../services/auth_storage.dart';
import '../services/seller_products_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';
import '../widgets/summary_card.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  static const String routeName = AppRoutes.products;

  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SellerProductsService _productsService = SellerProductsService();
  final AuthStorage _authStorage = AuthStorage();

  static const Duration _requestTimeout = Duration(seconds: 20);

  Timer? _searchDebounce;
  String _searchQuery = '';
  int _statusIndex = 0;
  int _stockIndex = 0;

  List<SellerProductSummary> _products = [];
  SellerProductListMeta? _meta;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _authToken;
  bool _initialLoadStarted = false;

  static const List<String> _statusFilterKeys = [
    'all',
    'active',
    'inactive',
  ];

  static const List<String> _stockFilterKeys = [
    'all',
    'low',
    'out',
  ];

  static const int _lowStockThreshold = 8;

  @override
  void initState() {
    super.initState();
    debugPrint('ProductsScreen initState');
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
    debugPrint('ProductsScreen dispose');
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
      debugPrint('ProductsScreen scroll near end, loading more');
      _loadProducts(reset: false);
    }
  }

  Future<void> _loadInitial() async {
    final l10n = AppLocalizations.of(context);
    debugPrint('ProductsScreen loadInitial start');
    final token = await _authStorage.readToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      debugPrint('ProductsScreen loadInitial: no token');
      await _handleUnauthenticated(l10n);
      return;
    }
    debugPrint('ProductsScreen loadInitial: token loaded');
    setState(() {
      _authToken = token;
    });
    await _loadProducts(reset: true);
  }

  Future<void> _loadProducts({required bool reset}) async {
    final token = _authToken;
    if (token == null || token.isEmpty) {
      final l10n = AppLocalizations.of(context);
      debugPrint('ProductsScreen loadProducts: missing token');
      await _handleUnauthenticated(l10n);
      return;
    }

    if (reset) {
      debugPrint('ProductsScreen loadProducts reset=true');
      setState(() {
        _isLoading = true;
        _meta = null;
      });
    } else {
      debugPrint('ProductsScreen loadProducts reset=false');
      setState(() {
        _isLoadingMore = true;
      });
    }

    final nextPage = reset ? 1 : (_meta?.currentPage ?? 1) + 1;
    if (!reset && _meta != null && nextPage > (_meta?.lastPage ?? 1)) {
      debugPrint('ProductsScreen loadProducts: reached last page');
      setState(() {
        _isLoadingMore = false;
      });
      return;
    }

    try {
      debugPrint(
        'ProductsScreen fetchProducts page=$nextPage search="$_searchQuery" status=${_statusFilterParam()} per_page=${_meta?.perPage ?? 10}',
      );
      final response = await _productsService.fetchProducts(
        authToken: token,
        searchKey: _searchQuery,
        productStatus: _statusFilterParam(),
        perPage: _meta?.perPage ?? 10,
        page: nextPage,
      ).timeout(_requestTimeout);
      if (!mounted) return;
      debugPrint(
        'ProductsScreen fetchProducts success count=${response.products.length} meta=${response.meta?.currentPage}/${response.meta?.lastPage}',
      );
      setState(() {
        _meta = response.meta ?? _meta;
        if (reset) {
          _products = response.products;
        } else {
          _products = [..._products, ...response.products];
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (_isUnauthenticatedError(e)) {
        debugPrint('ProductsScreen loadProducts: unauthenticated');
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('ProductsScreen loadProducts failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      showAppSnackBar(context, _errorMessage(e, l10n.productsLoadFailed));
    }
  }

  bool get _hasMore {
    final meta = _meta;
    if (meta == null) return false;
    return meta.currentPage < meta.lastPage;
  }

  int? _statusFilterParam() {
    final key = _statusFilterKeys[_statusIndex];
    switch (key) {
      case 'active':
        return 1;
      case 'inactive':
        return 2;
    }
    return null;
  }

  void _onSearchChanged(String value) {
    debugPrint('ProductsScreen search changed: "$value"');
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      debugPrint('ProductsScreen search debounce fired: "$value"');
      setState(() {
        _searchQuery = value;
      });
      _loadProducts(reset: true);
    });
  }

  List<SellerProductSummary> get _filteredProducts {
    final key = _stockFilterKeys[_stockIndex];
    if (key == 'all') return _products;
    return _products.where((product) {
      final quantity = product.quantity;
      if (quantity == null) return false;
      if (key == 'out') {
        return quantity == 0;
      }
      if (key == 'low') {
        return quantity > 0 && quantity <= _lowStockThreshold;
      }
      return true;
    }).toList();
  }

  int get _activeCount {
    return _products.where((product) => product.isActive).length;
  }

  int get _lowStockCount {
    return _products.where((product) {
      final quantity = product.quantity;
      if (quantity == null) return false;
      return quantity > 0 && quantity <= _lowStockThreshold;
    }).length;
  }

  Future<void> _openAddProduct() async {
    final l10n = AppLocalizations.of(context);
    debugPrint('ProductsScreen open add product');
    final result = await Navigator.of(context).push<ProductFormResult>(
      MaterialPageRoute(
        builder: (_) => const AddProductScreen(),
      ),
    );
    if (!mounted) return;
    debugPrint('ProductsScreen add product result: ${result?.action}');
    if (result?.action == ProductFormAction.saved) {
      await _loadProducts(reset: true);
      showAppSnackBar(context, l10n.addProductSubmittedMessage);
    }
  }

  Future<void> _openEditProduct(SellerProductSummary product) async {
    final l10n = AppLocalizations.of(context);
    debugPrint('ProductsScreen open edit product: id=${product.id}');
    final result = await Navigator.of(context).push<ProductFormResult>(
      MaterialPageRoute(
        builder: (_) => AddProductScreen(productId: product.id),
      ),
    );
    if (!mounted) return;
    debugPrint('ProductsScreen edit product result: ${result?.action}');
    if (result?.action == ProductFormAction.deleted) {
      await _loadProducts(reset: true);
      showAppSnackBar(context, l10n.editProductDeletedMessage);
      return;
    }
    if (result?.action == ProductFormAction.saved) {
      await _loadProducts(reset: true);
      showAppSnackBar(context, l10n.editProductUpdatedMessage);
    }
  }

  Future<void> _showQuickActions(SellerProductSummary product) async {
    final l10n = AppLocalizations.of(context);
    debugPrint('ProductsScreen quick actions open: id=${product.id}');
    final action = await showModalBottomSheet<_QuickAction>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: kBrandColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.toggle_on_outlined),
              title: Text(l10n.productsActionToggleStatus),
              onTap: () => Navigator.of(context).pop(_QuickAction.status),
            ),
            ListTile(
              leading: const Icon(Icons.percent),
              title: Text(l10n.productsActionUpdateDiscount),
              onTap: () => Navigator.of(context).pop(_QuickAction.discount),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text(l10n.productsActionUpdatePrice),
              onTap: () => Navigator.of(context).pop(_QuickAction.price),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(l10n.productsActionUpdateStock),
              onTap: () => Navigator.of(context).pop(_QuickAction.stock),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;
    debugPrint('ProductsScreen quick actions selected: $action');
    switch (action) {
      case _QuickAction.status:
        await _toggleStatus(product);
        break;
      case _QuickAction.discount:
        await _updateDiscount(product);
        break;
      case _QuickAction.price:
        await _updatePrice(product);
        break;
      case _QuickAction.stock:
        await _updateStock(product);
        break;
    }
  }

  Future<void> _toggleStatus(SellerProductSummary product) async {
    final token = _authToken;
    if (token == null || token.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final nextStatus = product.isActive ? 2 : 1;
    debugPrint(
      'ProductsScreen update status: id=${product.id}, status=$nextStatus',
    );
    try {
      await _productsService.updateStatus(
        authToken: token,
        productId: product.id,
        status: nextStatus,
      );
      if (!mounted) return;
      await _loadProducts(reset: true);
      showAppSnackBar(context, l10n.productsStatusUpdated);
    } catch (e, stackTrace) {
      await _handleServiceError(e, stackTrace, l10n.productsStatusUpdateFailed);
    }
  }

  Future<void> _updateDiscount(SellerProductSummary product) async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) return;

    debugPrint('ProductsScreen update discount start: id=${product.id}');
    final input = await _showDiscountDialog(l10n);
    if (input == null) return;

    try {
      debugPrint(
        'ProductsScreen update discount payload: id=${product.id}, type=${input.type}, amount=${input.amount}',
      );
      await _productsService.updateDiscount(
        authToken: token,
        productId: product.id,
        discountAmountType: input.type,
        discountAmount: input.amount,
      );
      if (!mounted) return;
      await _loadProducts(reset: true);
      showAppSnackBar(context, l10n.productsDiscountUpdated);
    } catch (e, stackTrace) {
      await _handleServiceError(
        e,
        stackTrace,
        l10n.productsDiscountUpdateFailed,
      );
    }
  }

  Future<void> _updatePrice(SellerProductSummary product) async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) return;

    debugPrint('ProductsScreen update price start: id=${product.id}');
    if (product.isVariable) {
      final variations = await _showVariationPriceDialog(product, l10n);
      if (variations == null) return;
      try {
        await _productsService.updatePrice(
          authToken: token,
          productId: product.id,
          hasVariant: 1,
          variations: variations,
        );
        if (!mounted) return;
        await _loadProducts(reset: true);
        showAppSnackBar(context, l10n.productsPriceUpdated);
      } catch (e, stackTrace) {
        await _handleServiceError(
          e,
          stackTrace,
          l10n.productsPriceUpdateFailed,
        );
      }
      return;
    }

    final input = await _showPriceDialog(l10n);
    if (input == null) return;

    try {
      debugPrint(
        'ProductsScreen update price payload: id=${product.id}, purchase=${input.purchasePrice}, unit=${input.unitPrice}',
      );
      await _productsService.updatePrice(
        authToken: token,
        productId: product.id,
        hasVariant: 2,
        purchasePrice: input.purchasePrice,
        unitPrice: input.unitPrice,
      );
      if (!mounted) return;
      await _loadProducts(reset: true);
      showAppSnackBar(context, l10n.productsPriceUpdated);
    } catch (e, stackTrace) {
      await _handleServiceError(
        e,
        stackTrace,
        l10n.productsPriceUpdateFailed,
      );
    }
  }

  Future<void> _updateStock(SellerProductSummary product) async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) return;

    debugPrint('ProductsScreen update stock start: id=${product.id}');
    if (product.isVariable) {
      final variations = await _showVariationStockDialog(product, l10n);
      if (variations == null) return;
      try {
        await _productsService.updateStock(
          authToken: token,
          productId: product.id,
          hasVariant: 1,
          variations: variations,
        );
        if (!mounted) return;
        await _loadProducts(reset: true);
        showAppSnackBar(context, l10n.productsStockUpdated);
      } catch (e, stackTrace) {
        await _handleServiceError(
          e,
          stackTrace,
          l10n.productsStockUpdateFailed,
        );
      }
      return;
    }

    final quantity = await _showStockDialog(l10n);
    if (quantity == null) return;

    try {
      debugPrint(
        'ProductsScreen update stock payload: id=${product.id}, quantity=$quantity',
      );
      await _productsService.updateStock(
        authToken: token,
        productId: product.id,
        hasVariant: 2,
        quantity: quantity,
      );
      if (!mounted) return;
      await _loadProducts(reset: true);
      showAppSnackBar(context, l10n.productsStockUpdated);
    } catch (e, stackTrace) {
      await _handleServiceError(
        e,
        stackTrace,
        l10n.productsStockUpdateFailed,
      );
    }
  }

  Future<void> _handleServiceError(
    Object error,
    StackTrace stackTrace,
    String fallbackMessage,
  ) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (_isUnauthenticatedError(error)) {
      debugPrint('ProductsScreen action error: unauthenticated');
      await _handleUnauthenticated(l10n);
      return;
    }
    debugPrint('ProductsScreen action failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    if (mounted) {
      showAppSnackBar(context, _errorMessage(error, fallbackMessage));
    }
  }

  Future<_DiscountInput?> _showDiscountDialog(AppLocalizations l10n) async {
    final amountController = TextEditingController();
    int type = 2;

    debugPrint('ProductsScreen show discount dialog');
    final result = await showDialog<_DiscountInput>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.productsDiscountDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: type,
              decoration:
                  InputDecoration(labelText: l10n.productsDiscountTypeLabel),
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Text(l10n.productsDiscountTypeFixed),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text(l10n.productsDiscountTypePercent),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                type = value;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: l10n.productsDiscountAmountLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.addProductCancel),
          ),
          FilledButton(
            onPressed: () {
              final amount =
                  double.tryParse(amountController.text.trim()) ?? 0;
              Navigator.of(context).pop(
                _DiscountInput(type: type, amount: amount),
              );
            },
            child: Text(l10n.editProductSaveAction),
          ),
        ],
      ),
    );

    amountController.dispose();
    return result;
  }

  Future<_PriceInput?> _showPriceDialog(AppLocalizations l10n) async {
    final purchaseController = TextEditingController();
    final unitController = TextEditingController();

    debugPrint('ProductsScreen show price dialog');
    final result = await showDialog<_PriceInput>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.productsPriceDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: purchaseController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: l10n.productsPurchasePriceLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: l10n.productsUnitPriceLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.addProductCancel),
          ),
          FilledButton(
            onPressed: () {
              final purchase =
                  double.tryParse(purchaseController.text.trim()) ?? 0;
              final unit = double.tryParse(unitController.text.trim()) ?? 0;
              Navigator.of(context).pop(
                _PriceInput(purchasePrice: purchase, unitPrice: unit),
              );
            },
            child: Text(l10n.editProductSaveAction),
          ),
        ],
      ),
    );

    purchaseController.dispose();
    unitController.dispose();
    return result;
  }

  Future<int?> _showStockDialog(AppLocalizations l10n) async {
    final quantityController = TextEditingController();

    debugPrint('ProductsScreen show stock dialog');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.productsStockDialogTitle),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.productsQuantityLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.addProductCancel),
          ),
          FilledButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
              Navigator.of(context).pop(quantity);
            },
            child: Text(l10n.editProductSaveAction),
          ),
        ],
      ),
    );

    quantityController.dispose();
    return result;
  }

  Future<List<Map<String, dynamic>>?> _showVariationPriceDialog(
    SellerProductSummary product,
    AppLocalizations l10n,
  ) async {
    final token = _authToken;
    if (token == null || token.isEmpty) return null;

    debugPrint(
      'ProductsScreen show variation price dialog: id=${product.id}',
    );
    try {
      final details = await _productsService.fetchProductDetails(
        authToken: token,
        productId: product.id,
      );
      final variations = details.variations;
      if (variations.isEmpty) {
        debugPrint('ProductsScreen variation price: no variations');
        showAppSnackBar(context, l10n.productsVariationsEmpty);
        return null;
      }

      final controllers = variations
          .map(
            (variation) => _VariationPriceInput(
              id: variation.id ?? 0,
              code: variation.code,
              purchaseController: TextEditingController(
                text: variation.purchasePrice?.toString() ?? '',
              ),
              unitController: TextEditingController(
                text: variation.unitPrice?.toString() ?? '',
              ),
            ),
          )
          .toList();

      final result = await showDialog<List<Map<String, dynamic>>>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.productsVariationPriceDialogTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controllers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = controllers[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.code.isNotEmpty
                          ? item.code
                          : l10n.productsVariationLabel(index + 1),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: item.purchaseController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.productsPurchasePriceLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: item.unitController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.productsUnitPriceLabel,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.addProductCancel),
            ),
            FilledButton(
              onPressed: () {
                final payload = controllers
                    .map(
                      (item) => {
                        'id': item.id,
                        'purchase_price':
                            double.tryParse(item.purchaseController.text) ?? 0,
                        'unit_price':
                            double.tryParse(item.unitController.text) ?? 0,
                      },
                    )
                    .toList();
                Navigator.of(context).pop(payload);
              },
              child: Text(l10n.editProductSaveAction),
            ),
          ],
        ),
      );

      for (final item in controllers) {
        item.purchaseController.dispose();
        item.unitController.dispose();
      }

      return result;
    } catch (e, stackTrace) {
      await _handleServiceError(
        e,
        stackTrace,
        l10n.productsPriceUpdateFailed,
      );
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> _showVariationStockDialog(
    SellerProductSummary product,
    AppLocalizations l10n,
  ) async {
    final token = _authToken;
    if (token == null || token.isEmpty) return null;

    debugPrint(
      'ProductsScreen show variation stock dialog: id=${product.id}',
    );
    try {
      final details = await _productsService.fetchProductDetails(
        authToken: token,
        productId: product.id,
      );
      final variations = details.variations;
      if (variations.isEmpty) {
        debugPrint('ProductsScreen variation stock: no variations');
        showAppSnackBar(context, l10n.productsVariationsEmpty);
        return null;
      }

      final controllers = variations
          .map(
            (variation) => _VariationStockInput(
              id: variation.id ?? 0,
              code: variation.code,
              quantityController: TextEditingController(
                text: variation.quantity?.toString() ?? '',
              ),
            ),
          )
          .toList();

      final result = await showDialog<List<Map<String, dynamic>>>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.productsVariationStockDialogTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controllers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = controllers[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.code.isNotEmpty
                          ? item.code
                          : l10n.productsVariationLabel(index + 1),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: item.quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.productsQuantityLabel,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.addProductCancel),
            ),
            FilledButton(
              onPressed: () {
                final payload = controllers
                    .map(
                      (item) => {
                        'id': item.id,
                        'quantity':
                            int.tryParse(item.quantityController.text) ?? 0,
                      },
                    )
                    .toList();
                Navigator.of(context).pop(payload);
              },
              child: Text(l10n.editProductSaveAction),
            ),
          ],
        ),
      );

      for (final item in controllers) {
        item.quantityController.dispose();
      }

      return result;
    } catch (e, stackTrace) {
      await _handleServiceError(
        e,
        stackTrace,
        l10n.productsStockUpdateFailed,
      );
      return null;
    }
  }

  Future<void> _handleUnauthenticated(AppLocalizations l10n) async {
    await _authStorage.clearToken();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
    });
    debugPrint('ProductsScreen unauthenticated: redirecting to login');
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

  Color _accentForProduct(int id) {
    const accents = [
      Color(0xFFECE7FF),
      Color(0xFFE7F1FF),
      Color(0xFFFFF1E3),
      Color(0xFFFFE9F0),
      Color(0xFFE6F4F1),
    ];
    return accents[id.abs() % accents.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final products = _filteredProducts;

    final summaries = [
      SummaryItem(
        label: l10n.productsSummaryTotal,
        value: _meta?.total ?? _products.length,
        color: kBrandColor,
      ),
      SummaryItem(
        label: l10n.productsSummaryActive,
        value: _activeCount,
        color: kSuccessColor,
      ),
      SummaryItem(
        label: l10n.productsSummaryLowStock,
        value: _lowStockCount,
        color: kWarningColor,
      ),
    ];

    return Scaffold(
      appBar: const SellerAppBar(),
      drawer: const SellerDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddProduct,
        backgroundColor: kBrandColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => _loadProducts(reset: true),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: l10n.productsSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                debugPrint('ProductsScreen search cleared');
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _loadProducts(reset: true);
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
                      children:
                          List.generate(_statusFilterKeys.length, (index) {
                        final isSelected = _statusIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(
                              _statusFilterLabel(
                                l10n,
                                _statusFilterKeys[index],
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              debugPrint(
                                'ProductsScreen status filter selected: ${_statusFilterKeys[index]}',
                              );
                              setState(() {
                                _statusIndex = index;
                              });
                              _loadProducts(reset: true);
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
                  padding: const EdgeInsets.only(left: 24, bottom: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          List.generate(_stockFilterKeys.length, (index) {
                        final isSelected = _stockIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(
                              _stockFilterLabel(
                                l10n,
                                _stockFilterKeys[index],
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              debugPrint(
                                'ProductsScreen stock filter selected: ${_stockFilterKeys[index]}',
                              );
                              setState(() {
                                _stockIndex = index;
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
                          l10n.productsListTitle(products.length),
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        l10n.productsSortNewest,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kBrandColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        if (products.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              l10n.productsEmptyMessage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: kInkColor.withOpacity(0.7),
                              ),
                            ),
                          )
                        else
                          ...products.map(
                            (product) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ProductCard(
                                product: product,
                                accent: _accentForProduct(product.id),
                                onTap: () => _openEditProduct(product),
                                onActions: () => _showQuickActions(product),
                              ),
                            ),
                          ),
                        if (_isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
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
        selectedIndex: 1,
        onTap: (index) => handleNavTap(context, index),
      ),
    );
  }
}

enum _QuickAction { status, discount, price, stock }

class _DiscountInput {
  final int type;
  final double amount;

  const _DiscountInput({required this.type, required this.amount});
}

class _PriceInput {
  final double purchasePrice;
  final double unitPrice;

  const _PriceInput({required this.purchasePrice, required this.unitPrice});
}

class _VariationPriceInput {
  final int id;
  final String code;
  final TextEditingController purchaseController;
  final TextEditingController unitController;

  const _VariationPriceInput({
    required this.id,
    required this.code,
    required this.purchaseController,
    required this.unitController,
  });
}

class _VariationStockInput {
  final int id;
  final String code;
  final TextEditingController quantityController;

  const _VariationStockInput({
    required this.id,
    required this.code,
    required this.quantityController,
  });
}

String _statusFilterLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'all':
      return l10n.productsFilterAll;
    case 'active':
      return l10n.productsFilterActive;
    case 'inactive':
      return l10n.productsFilterInactive;
  }
  return key;
}

String _stockFilterLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'all':
      return l10n.productsStockFilterAll;
    case 'low':
      return l10n.productsStockFilterLow;
    case 'out':
      return l10n.productsStockFilterOut;
  }
  return key;
}

String _productStatusLabel(AppLocalizations l10n, int status) {
  if (status == 1) {
    return l10n.productsStatusActive;
  }
  return l10n.productsStatusInactive;
}

class _ProductCard extends StatelessWidget {
  final SellerProductSummary product;
  final Color accent;
  final VoidCallback? onTap;
  final VoidCallback? onActions;

  const _ProductCard({
    required this.product,
    required this.accent,
    this.onTap,
    this.onActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final stockLabel = _stockLabel(l10n, product.quantity);
    final stockColor = _stockColor(product.quantity);
    final statusLabel = _productStatusLabel(l10n, product.status);
    final statusColor = product.status == 1 ? kSuccessColor : kWarningColor;
    final priceLabel = _formatPrice(product.price ?? product.basePrice);
    final subtitle = product.permalink.isNotEmpty
        ? product.permalink
        : '${l10n.productsProductId} #${product.id}';
    final thumbnailUrl = ApiConfig.resolveMediaUrl(product.thumbnailImage);

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
            boxShadow: kSoftShadow,
          ),
          child: Row(
            children: [
              _ProductThumbnail(
                name: product.name,
                accent: accent,
                imageUrl: thumbnailUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.isNotEmpty
                          ? product.name
                          : l10n.productsUnnamed,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: kInkColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stockLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: stockColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    priceLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onActions != null) ...[
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: onActions,
                      icon: const Icon(Icons.more_horiz),
                      tooltip: l10n.productsQuickActions,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double? price) {
    if (price == null) return '--';
    final rounded = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
    return rounded;
  }

  String _stockLabel(AppLocalizations l10n, int? quantity) {
    if (quantity == null) {
      return l10n.productsStockUnknown;
    }
    if (quantity == 0) {
      return l10n.productsStockOut;
    }
    if (quantity <= _ProductsScreenState._lowStockThreshold) {
      return l10n.productsStockLow(quantity);
    }
    return l10n.productsStockAvailable(quantity);
  }

  Color _stockColor(int? quantity) {
    if (quantity == null) return kInkColor.withOpacity(0.5);
    if (quantity == 0) return kDangerColor;
    if (quantity <= _ProductsScreenState._lowStockThreshold) {
      return kWarningColor;
    }
    return kSuccessColor;
  }
}

class _ProductThumbnail extends StatelessWidget {
  final String name;
  final Color accent;
  final String imageUrl;

  const _ProductThumbnail({
    required this.name,
    required this.accent,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initialLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(theme, initialLetter),
        ),
      );
    }

    return _fallback(theme, initialLetter);
  }

  Widget _fallback(ThemeData theme, String initialLetter) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          initialLetter,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: kInkColor,
          ),
        ),
      ),
    );
  }
}
