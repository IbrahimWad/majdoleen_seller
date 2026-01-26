import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_shadows.dart';
import '../models/seller_product_models.dart';
import '../services/auth_storage.dart';
import '../services/seller_products_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';

class ProductDetailsScreen extends StatefulWidget {
  final SellerProductSummary product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final SellerProductsService _productsService = SellerProductsService();
  final AuthStorage _authStorage = AuthStorage();

  static const Duration _requestTimeout = Duration(seconds: 60);

  bool _isLoading = true;
  SellerProductDetails? _fullProductDetails;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    final token = await _authStorage.readToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      final l10n = AppLocalizations.of(context);
      debugPrint('ProductDetailsScreen: no token');
      _handleUnauthenticated(l10n);
      return;
    }

    try {
      debugPrint('ProductDetailsScreen: fetching product ${widget.product.id}');
      final details = await _productsService
          .fetchProductDetails(
            authToken: token,
            productId: widget.product.id,
          )
          .timeout(_requestTimeout);

      if (!mounted) return;

      debugPrint('ProductDetailsScreen: product loaded');
      setState(() {
        _fullProductDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      debugPrint('ProductDetailsScreen: failed to load product - $e');
      setState(() {
        _isLoading = false;
      });
      showAppSnackBar(context, l10n.productsLoadFailed);
    }
  }

  Future<void> _handleUnauthenticated(AppLocalizations l10n) async {
    await _authStorage.clearToken();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    debugPrint('ProductDetailsScreen unauthenticated: redirecting to login');
    showAppSnackBar(context, l10n.storeProfileAuthRequired);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final product = widget.product;
    final thumbnailUrl = ApiConfig.resolveMediaUrl(product.thumbnailImage);

    return Scaffold(
      extendBody: true,
      appBar: const SellerAppBar(),
      drawer: const SellerDrawer(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: SellerBottomBar.bodyBottomPadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Gallery Section
                    _buildImageGallery(thumbnailUrl),

                    const SizedBox(height: 24),

                    // Product Info Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            product.name.isNotEmpty ? product.name : l10n.productsUnnamed,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Product ID and Permalink
                          Text(
                            product.permalink.isNotEmpty
                                ? product.permalink
                                : '${l10n.productsProductId} #${product.id}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: kInkColor.withOpacity(0.6),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Status and Stock Status Row
                          Row(
                            children: [
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: product.status == 1
                                      ? kSuccessColor.withOpacity(0.15)
                                      : kWarningColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  product.status == 1
                                      ? l10n.productsStatusActive
                                      : l10n.productsStatusInactive,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: product.status == 1
                                        ? kSuccessColor
                                        : kWarningColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Stock Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStockColor(product.quantity)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _getStockLabel(l10n, product.quantity),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _getStockColor(product.quantity),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Price Section
                    _buildPriceSection(theme, l10n, product),

                    const SizedBox(height: 24),

                    // Stock Information
                    _buildStockSection(theme, l10n, product),

                    const SizedBox(height: 24),

                    // Description Section - Use full product details if available
                    if (_fullProductDetails?.description.isNotEmpty ?? false)
                      _buildDescriptionSection(theme, l10n, _fullProductDetails!.description)
                    else if (product.description?.isNotEmpty ?? false)
                      _buildDescriptionSection(theme, l10n, product.description ?? ''),

                    const SizedBox(height: 24),

                    // Product Details Grid
                    _buildDetailsGrid(theme, l10n, product),

                    const SizedBox(height: 24),

                    // Features Section
                    _buildFeaturesSection(theme, l10n, product),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: Material(
        type: MaterialType.transparency,
        child: SellerBottomBar(
          selectedIndex: 1,
          onTap: (index) {
            // Handle navigation
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildImageGallery(String thumbnailUrl) {
    return Container(
      width: double.infinity,
      height: 300,
      color: kCardColor,
      child: Stack(
        children: [
          // Main Image
          if (thumbnailUrl.isNotEmpty)
            Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),

          // Floating back button
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: kSoftShadow,
                ),
                child: const Icon(Icons.arrow_back, color: kInkColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: kCardColor,
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: kInkColor.withOpacity(0.3),
          size: 64,
        ),
      ),
    );
  }

  Widget _buildPriceSection(
    ThemeData theme,
    AppLocalizations l10n,
    SellerProductSummary product,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kBrandColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kBrandColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.productsUnitPriceLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: kInkColor.withOpacity(0.7),
                  ),
                ),
                Text(
                  _formatPrice(product.price ?? product.basePrice),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: kBrandColor,
                  ),
                ),
              ],
            ),
            if ((product.discount?.amount ?? 0) > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.productsActionUpdateDiscount,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: kInkColor.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${(product.discount?.amount ?? 0).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: kWarningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockSection(
    ThemeData theme,
    AppLocalizations l10n,
    SellerProductSummary product,
  ) {
    final quantity = product.quantity ?? 0;
    final isLowStock = quantity > 0 && quantity <= 8;
    final isOutOfStock = quantity == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kBrandColor.withOpacity(0.2),
          ),
          boxShadow: kSoftShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productsQuantityLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quantity.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (isOutOfStock)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kDangerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.productsStockOut,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: kDangerColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isLowStock)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kWarningColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.productsStockLow(quantity),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: kWarningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kSuccessColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.productsStockAvailable(quantity),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: kSuccessColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(
    ThemeData theme,
    AppLocalizations l10n,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addProductDescriptionLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kBrandColor.withOpacity(0.1),
              ),
            ),
            child: Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: kInkColor.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(
    ThemeData theme,
    AppLocalizations l10n,
    SellerProductSummary product,
  ) {
    final details = [
      _DetailItem(
        label: l10n.productsProductId,
        value: product.id.toString(),
      ),
      _DetailItem(
        label: 'Product Type',
        value: product.isVariable ? 'Variable' : 'Simple',
      ),
      _DetailItem(
        label: 'Status',
        value: product.isActive ? 'Active' : 'Inactive',
      ),
      _DetailItem(
        label: 'Approved',
        value: product.isApproved == 1 ? 'Yes' : 'No',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: details
                .map(
                  (detail) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kBrandColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          detail.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: kInkColor.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          detail.value,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(
    ThemeData theme,
    AppLocalizations l10n,
    SellerProductSummary product,
  ) {
    final features = <MapEntry<String, bool>>[
      MapEntry('Featured', product.isFeatured == 1),
      MapEntry('Approved', product.isApproved == 1),
      MapEntry('Variable', product.isVariable),
    ];

    final enabledFeatures = features.where((f) => f.value).toList();

    if (enabledFeatures.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: enabledFeatures
                .map(
                  (feature) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: kSuccessColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kSuccessColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: kSuccessColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          feature.key,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: kSuccessColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double? price) {
    if (price == null) return '--';
    final rounded = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
    return rounded;
  }

  Color _getStockColor(int? quantity) {
    if (quantity == null) return kInkColor.withOpacity(0.5);
    if (quantity == 0) return kDangerColor;
    if (quantity <= 8) return kWarningColor;
    return kSuccessColor;
  }

  String _getStockLabel(AppLocalizations l10n, int? quantity) {
    if (quantity == null) return l10n.productsStockUnknown;
    if (quantity == 0) return l10n.productsStockOut;
    if (quantity <= 8) return l10n.productsStockLow(quantity);
    return l10n.productsStockAvailable(quantity);
  }
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem({required this.label, required this.value});
}
