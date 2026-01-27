import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../models/seller_product_models.dart';
import '../services/auth_storage.dart';
import '../services/seller_products_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/form_section_header.dart';

class AddProductScreen extends StatefulWidget {
  static const String routeName = AppRoutes.addProduct;
  final int? productId;

  const AddProductScreen({super.key, this.productId});

  bool get isEditing => productId != null;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final SellerProductsService _productsService = SellerProductsService();
  final AuthStorage _authStorage = AuthStorage();
  final ImagePicker _imagePicker = ImagePicker();
  //roji test 2

  bool _initialLoadStarted = false;
  int _stepIndex = 0;
  bool _publishNow = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  String? _authToken;
  SellerProductOptions _options = const SellerProductOptions();

  int _productType = 2;
  bool _permalinkDirty = false;
  bool _syncingPermalink = false;
  int _discountType = 2;

  SellerProductOptionItem? _selectedUnit;
  SellerProductOptionItem? _selectedCondition;

  int? _thumbnailFileId;
  String? _thumbnailUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _permalinkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  final List<_VariationFormData> _variations = [];

  static const List<String> _stepKeys = [
    'basics',
    'pricing',
    'media',
  ];

  @override
  void initState() {
    super.initState();
    debugPrint(
      'AddProductScreen initState: isEditing=${widget.isEditing}, productId=${widget.productId}',
    );
    _nameController.addListener(_syncPermalinkFromName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;
    debugPrint('AddProductScreen didChangeDependencies: loadData');
    _loadData();
  }

  @override
  void dispose() {
    debugPrint('AddProductScreen dispose');
    _nameController.removeListener(_syncPermalinkFromName);
    _nameController.dispose();
    _permalinkController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    for (final variation in _variations) {
      variation.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final l10n = AppLocalizations.of(context);
    debugPrint('AddProductScreen loadData start');
    final token = await _authStorage.readToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      debugPrint('AddProductScreen loadData: missing token');
      await _handleUnauthenticated(l10n);
      return;
    }
    _authToken = token;

    try {
      debugPrint('AddProductScreen fetchOptions start');
      final options = await _productsService.fetchOptions(authToken: token);
      debugPrint(
        'AddProductScreen fetchOptions success: units=${options.units.length}, conditions=${options.conditions.length}, categories=${options.categories.length}, brands=${options.brands.length}, tags=${options.tags.length}',
      );
      SellerProductDetails? details;
      if (widget.productId != null) {
        debugPrint(
          'AddProductScreen fetchProductDetails start: id=${widget.productId}',
        );
        details = await _productsService.fetchProductDetails(
          authToken: token,
          productId: widget.productId!,
        );
        debugPrint(
          'AddProductScreen fetchProductDetails success: id=${details.id}, type=${details.productType}, variations=${details.variations.length}',
        );
      }
      if (!mounted) return;
      setState(() {
        _options = options;
        _isLoading = false;
      });
      if (details != null) {
        debugPrint('AddProductScreen apply details');
        _applyDetails(details);
      } else {
        debugPrint('AddProductScreen apply defaults');
        _applyDefaults();
      }
    } catch (e, stackTrace) {
      debugPrint('AddProductScreen loadData failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      setState(() {
        _isLoading = false;
      });
      showAppSnackBar(context, _errorMessage(e, l10n.productsLoadFailed));
    }
  }

  void _applyDefaults() {
    setState(() {
      _selectedUnit ??= _options.units.isNotEmpty ? _options.units.first : null;
      _selectedCondition ??=
          _options.conditions.isNotEmpty ? _options.conditions.first : null;
    });
    debugPrint(
      "AddProductScreen applyDefaults: unit=${_selectedUnit?.name ?? 'none'}, condition=${_selectedCondition?.name ?? 'none'}",
    );
  }

  void _applyDetails(SellerProductDetails details) {
    _permalinkDirty = true;
    _nameController.text = details.name;
    _permalinkController.text = details.permalink;
    _descriptionController.text = details.description;
    _purchasePriceController.text = details.purchasePrice?.toString() ?? '';
    _unitPriceController.text = details.unitPrice?.toString() ?? '';
    _quantityController.text = details.quantity?.toString() ?? '';
    _discountController.text = details.discountAmount?.toString() ?? '';

    final detailsThumbnailUrl = details.thumbnailImageUrl;
    setState(() {
      _productType = details.productType;
      _publishNow = details.status == 1;
      _discountType = details.discountAmountType ?? _discountType;
      _thumbnailFileId = details.thumbnailImageId;
      _thumbnailUrl = _resolveMediaUrl(detailsThumbnailUrl);
      _selectedUnit = _matchOption(
        _options.units,
        details.unitId,
        null,
      );
      _selectedCondition = _matchOption(
        _options.conditions,
        details.conditionId,
        null,
      );
    });

    debugPrint(
      "AddProductScreen details applied: type=$_productType publish=$_publishNow unit=${_selectedUnit?.name ?? 'none'} condition=${_selectedCondition?.name ?? 'none'}",
    );
    _setVariations(details.variations);
    _applyDefaults();
  }

  SellerProductOptionItem? _matchOption(
    List<SellerProductOptionItem> options,
    int? id,
    String? name,
  ) {
    if (options.isEmpty) return null;
    if (id != null) {
      for (final option in options) {
        if (option.id == id) return option;
      }
    }
    if (name != null) {
      for (final option in options) {
        if (option.name.toLowerCase() == name.toLowerCase()) return option;
      }
    }
    return options.first;
  }

  void _setVariations(List<SellerProductVariation> variations) {
    for (final variation in _variations) {
      variation.dispose();
    }
    _variations
      ..clear()
      ..addAll(
        variations.map(
          (variation) => _VariationFormData(
            id: variation.id,
            code: variation.code,
            purchasePrice: variation.purchasePrice,
            unitPrice: variation.unitPrice,
            quantity: variation.quantity,
          ),
        ),
      );
    if (_productType == 1 && _variations.isEmpty) {
      _variations.add(_VariationFormData());
    }
  }

  void _syncPermalinkFromName() {
    if (_permalinkDirty) return;
    final slug = _slugify(_nameController.text);
    if (slug == _permalinkController.text) return;
    _syncingPermalink = true;
    _permalinkController.text = slug;
    _syncingPermalink = false;
  }

  void _goNext() {
    if (_stepIndex == _stepKeys.length - 1) {
      _saveProduct();
      return;
    }
    setState(() {
      _stepIndex++;
    });
  }

  void _goBack() {
    if (_stepIndex == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _stepIndex--;
    });
  }

  void _saveDraft() {
    final l10n = AppLocalizations.of(context);
    showAppSnackBar(context, l10n.addProductDraftSavedMessage);
  }

  Future<void> _saveProduct() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppSnackBar(context, l10n.productsFormNameRequired);
      return;
    }

    final permalink = _permalinkController.text.trim().isEmpty
        ? _slugify(name)
        : _permalinkController.text.trim();
    if (permalink.isEmpty) {
      showAppSnackBar(context, l10n.productsFormPermalinkRequired);
      return;
    }

    if (_productType == 1 && _variations.isEmpty) {
      showAppSnackBar(context, l10n.productsFormVariationRequired);
      return;
    }

    final payload = <String, dynamic>{
      'name': name,
      'permalink': permalink,
      'product_type': _productType,
      'status': _publishNow ? 1 : 2,
      'discount_amount_type': _discountType,
      'discount_amount':
          double.tryParse(_discountController.text.trim()) ?? 0,
    };

    final unitValue = _selectedUnit?.id ?? _selectedUnit?.name;
    if (unitValue != null) {
      payload['unit'] = unitValue;
    }

    final conditionValue = _selectedCondition?.id ?? _selectedCondition?.name;
    if (conditionValue != null) {
      payload['condition'] = conditionValue;
    }

    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) {
      payload['description'] = description;
    }

    if (_thumbnailFileId != null) {
      payload['thumbnail_image'] = _thumbnailFileId;
    }

    if (_productType == 1) {
      final variationsPayload = _variations
          .map((variation) => variation.toPayload())
          .where((item) => item.isNotEmpty)
          .toList();
      if (variationsPayload.isEmpty) {
        showAppSnackBar(context, l10n.productsFormVariationRequired);
        return;
      }
      payload['variations'] = variationsPayload;
    } else {
      payload['purchase_price'] =
          double.tryParse(_purchasePriceController.text.trim()) ?? 0;
      payload['unit_price'] =
          double.tryParse(_unitPriceController.text.trim()) ?? 0;
      payload['quantity'] = int.tryParse(_quantityController.text.trim()) ?? 0;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.productId == null) {
        await _productsService.createProduct(
          authToken: token,
          payload: payload,
        );
      } else {
        await _productsService.updateProduct(
          authToken: token,
          productId: widget.productId!,
          payload: payload,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(const ProductFormResult.saved());
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('Save product failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      showAppSnackBar(context, _errorMessage(e, l10n.productsSaveFailed));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty || widget.productId == null) {
      await _handleUnauthenticated(l10n);
      return;
    }

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
                      color: kBrandColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: kBrandColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.editProductDeleteTitle,
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
                          l10n.editProductDeleteMessage,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: kInkColor.withOpacity(0.7),
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
                          color: kBrandColor.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        l10n.editProductDeleteCancel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: kBrandColor,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: kBrandColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.editProductDeleteConfirm,
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

    setState(() => _isSaving = true);
    try {
      await _productsService.deleteProduct(
        authToken: token,
        productId: widget.productId!,
      );
      if (!mounted) return;
      Navigator.of(context).pop(const ProductFormResult.deleted());
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('Delete product failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      showAppSnackBar(context, _errorMessage(e, l10n.productsDeleteFailed));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickThumbnail() async {
    if (_isUploadingImage) return;
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final file = File(picked.path);
      final fileSize = await file.length();
      if (fileSize > 4 * 1024 * 1024) {
        showAppSnackBar(context, l10n.productsImageTooLarge);
        return;
      }

      setState(() => _isUploadingImage = true);
      final upload = await _productsService.uploadProductMedia(
        authToken: token,
        file: file,
      );
      if (!mounted) return;
      setState(() {
        _thumbnailFileId = upload.fileId;
        _thumbnailUrl = _resolveMediaUrl(upload.url);
      });
    } catch (e, stackTrace) {
      debugPrint('Upload product image failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        showAppSnackBar(context, _errorMessage(e, l10n.productsImageUploadFailed));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _addVariation() {
    setState(() {
      _variations.add(_VariationFormData());
    });
  }

  void _removeVariation(int index) {
    setState(() {
      final variation = _variations.removeAt(index);
      variation.dispose();
    });
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

  String? _resolveMediaUrl(String? path) {
    final resolved = ApiConfig.resolveMediaUrl(path);
    return resolved.isEmpty ? null : resolved;
  }

  String _slugify(String value) {
    final lower = value.toLowerCase().trim();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9\s-]'), '');
    return cleaned
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
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
    final isEditing = widget.isEditing;
    final progress = (_stepIndex + 1) / _stepKeys.length;
    final stepLabel = _stepLabel(l10n, _stepKeys[_stepIndex]);
    final isLastStep = _stepIndex == _stepKeys.length - 1;
    final primaryActionLabel = isLastStep
        ? (isEditing ? l10n.editProductSaveAction : l10n.addProductPublish)
        : l10n.addProductNext;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editProductTitle : l10n.addProductTitle),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _confirmDelete,
              tooltip: l10n.editProductDeleteAction,
              icon: const Icon(Icons.delete_outline),
            )
          else
            TextButton(
              onPressed: _saveDraft,
              child: Text(l10n.addProductSaveDraft),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.addProductStepIndicator(
                                _stepIndex + 1,
                                _stepKeys.length,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: kInkColor.withOpacity(0.6),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              stepLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: kBrandColor.withOpacity(0.15),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(kBrandColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: KeyedSubtree(
                        key: ValueKey(_stepIndex),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: _buildStepContent(theme, l10n),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              TextButton(
                onPressed: _goBack,
                child: Text(
                  _stepIndex == 0 ? l10n.addProductCancel : l10n.addProductBack,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _isSaving ? null : _goNext,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(primaryActionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme, AppLocalizations l10n) {
    switch (_stepIndex) {
      case 0:
        return _buildBasicsStep(theme, l10n);
      case 1:
        return _buildPricingStep(theme, l10n);
      default:
        return _buildMediaStep(theme, l10n);
    }
  }

  Widget _buildBasicsStep(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionHeader(
          title: l10n.addProductBasicsTitle,
          subtitle: l10n.addProductBasicsSubtitle,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: l10n.addProductNameLabel),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _permalinkController,
          onChanged: (_) {
            if (_syncingPermalink) return;
            _permalinkDirty = true;
          },
          decoration: InputDecoration(labelText: l10n.productsPermalinkLabel),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          initialValue: _productType,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.productsTypeLabel),
          items: [
            DropdownMenuItem(
              value: 2,
              child: Text(l10n.productsTypeSingle),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text(l10n.productsTypeVariable),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _productType = value;
              if (_productType == 1 && _variations.isEmpty) {
                _variations.add(_VariationFormData());
              }
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SellerProductOptionItem>(
                initialValue: _selectedUnit,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.addProductUnitLabel),
                items: _options.units
                    .map(
                      (unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(
                          unit.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<SellerProductOptionItem>(
                initialValue: _selectedCondition,
                isExpanded: true,
                decoration:
                    InputDecoration(labelText: l10n.productsConditionLabel),
                items: _options.conditions
                    .map(
                      (condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(
                          condition.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.addProductDescriptionLabel,
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingStep(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionHeader(
          title: l10n.addProductPricingTitle,
          subtitle: l10n.addProductPricingSubtitle,
        ),
        const SizedBox(height: 16),
        if (_productType == 2) ...[
          TextFormField(
            controller: _purchasePriceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration:
                InputDecoration(labelText: l10n.productsPurchasePriceLabel),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _unitPriceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.productsUnitPriceLabel),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.productsQuantityLabel),
          ),
        ] else ...[
          Text(
            l10n.productsVariationsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ..._variations.asMap().entries.map((entry) {
            final index = entry.key;
            final variation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBrandColor.withOpacity(0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.productsVariationLabel(index + 1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeVariation(index),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    TextField(
                      controller: variation.codeController,
                      decoration: InputDecoration(
                        labelText: l10n.productsVariationCodeLabel,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: variation.purchasePriceController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.productsPurchasePriceLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: variation.unitPriceController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.productsUnitPriceLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: variation.quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.productsQuantityLabel,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          TextButton.icon(
            onPressed: _addVariation,
            icon: const Icon(Icons.add),
            label: Text(l10n.productsAddVariation),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          l10n.productsDiscountTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: _discountType,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.productsDiscountTypeLabel),
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
            setState(() {
              _discountType = value;
            });
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _discountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.productsDiscountAmountLabel),
        ),
      ],
    );
  }

  Widget _buildMediaStep(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionHeader(
          title: l10n.addProductMediaTitle,
          subtitle: l10n.addProductMediaSubtitle,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.productsThumbnailTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _ImageSlot(
          label: l10n.productsThumbnailLabel,
          imageUrl: _thumbnailUrl,
          isLoading: _isUploadingImage,
          onTap: _pickThumbnail,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          value: _publishNow,
          onChanged: (value) {
            setState(() {
              _publishNow = value;
            });
          },
          activeThumbColor: kBrandColor,
          title: Text(
            l10n.addProductPublishToggle,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: kInkColor,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBrandColor.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kBrandColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.sell_outlined, color: kBrandColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.addProductPublishNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum ProductFormAction { saved, deleted }

class ProductFormResult {
  final ProductFormAction action;

  const ProductFormResult.saved() : action = ProductFormAction.saved;
  const ProductFormResult.deleted() : action = ProductFormAction.deleted;
}

String _stepLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'basics':
      return l10n.addProductStepBasics;
    case 'pricing':
      return l10n.addProductStepPricing;
    case 'media':
      return l10n.addProductStepMedia;
  }
  return key;
}

class _VariationFormData {
  final int? id;
  final TextEditingController codeController;
  final TextEditingController purchasePriceController;
  final TextEditingController unitPriceController;
  final TextEditingController quantityController;

  _VariationFormData({
    this.id,
    String? code,
    double? purchasePrice,
    double? unitPrice,
    int? quantity,
  })  : codeController = TextEditingController(text: code ?? ''),
        purchasePriceController =
            TextEditingController(text: purchasePrice?.toString() ?? ''),
        unitPriceController =
            TextEditingController(text: unitPrice?.toString() ?? ''),
        quantityController =
            TextEditingController(text: quantity?.toString() ?? '');

  Map<String, dynamic> toPayload() {
    final code = codeController.text.trim();
    if (code.isEmpty) return const <String, dynamic>{};
    final payload = <String, dynamic>{
      'code': code,
      'purchase_price': double.tryParse(purchasePriceController.text.trim()) ?? 0,
      'unit_price': double.tryParse(unitPriceController.text.trim()) ?? 0,
      'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
    };
    if (id != null) {
      payload['id'] = id;
    }
    return payload;
  }

  void dispose() {
    codeController.dispose();
    purchasePriceController.dispose();
    unitPriceController.dispose();
    quantityController.dispose();
  }
}

class _ImageSlot extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback onTap;

  const _ImageSlot({
    required this.label,
    required this.imageUrl,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBrandColor.withOpacity(0.12)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(theme),
                ),
              )
            else
              _fallback(theme),
            if (isLoading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: kBrandColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.add_photo_alternate_outlined),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
