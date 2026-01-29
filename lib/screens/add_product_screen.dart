import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
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
  final List<SellerProductOptionItem> _selectedCategories = [];
  final List<SellerProductOptionItem> _selectedAttributes = [];
  final Map<int, List<SellerProductOptionItem>> _selectedAttributeValues = {};
  final List<SellerProductOptionItem> _selectedColors = [];
  bool _useColorVariants = false;
  final Map<int, List<SellerProductMediaUpload>> _colorVariantImages = {};
  final Set<int> _colorImageUploading = {};
  final List<SellerProductMediaUpload> _galleryImages = [];
  bool _isGalleryUploading = false;

  int? _thumbnailFileId;
  String? _thumbnailUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _permalinkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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
      "AddProductScreen applyDefaults: unit=${_selectedUnit?.name ?? 'none'}, condition=${_selectedCondition?.name ?? 'none'}, categories=${_selectedCategories.length}",
    );
  }

  void _applyDetails(SellerProductDetails details) {
    _permalinkDirty = true;
    _nameController.text = details.name;
    _permalinkController.text = details.permalink;
    _descriptionController.text = details.description;
    _unitPriceController.text = details.unitPrice?.toString() ?? '';
    _quantityController.text = details.quantity?.toString() ?? '';
    _discountController.text = details.discountAmount?.toString() ?? '';

    final detailsThumbnailUrl = details.thumbnailImageUrl;
    final matchedCategories = _matchCategories(details.categoryIds);
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
      _selectedCategories
        ..clear()
        ..addAll(matchedCategories);
      _galleryImages
        ..clear()
        ..addAll(_resolveGalleryUploads(details.galleryImages));
    });

    if (details.productType == 1) {
      _applyVariationSelectionsFromDetails(details);
      _applyColorVariantImagesFromDetails(details);
    } else {
      _colorVariantImages.clear();
      _colorImageUploading.clear();
      _useColorVariants = false;
    }

    debugPrint(
      "AddProductScreen details applied: type=$_productType publish=$_publishNow unit=${_selectedUnit?.name ?? 'none'} condition=${_selectedCondition?.name ?? 'none'} categories=${_selectedCategories.length}",
    );
    _setVariations(details.variations);
    if (_productType == 1) {
      _syncVariationsFromSelections();
    }
    _applyDefaults();
  }

  List<SellerProductMediaUpload> _resolveGalleryUploads(
    List<SellerProductMediaUpload> uploads,
  ) {
    return uploads
        .map((upload) {
          final url = _resolveMediaUrl(upload.url) ?? upload.url;
          return SellerProductMediaUpload(
            fileId: upload.fileId,
            url: url,
            localPath: upload.localPath,
          );
        })
        .where((upload) => upload.fileId > 0 || upload.url.isNotEmpty)
        .toList();
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

  String _resolveOptionName(
    SellerProductOptionItem value,
    List<SellerProductOptionItem> options,
  ) {
    final rawName = value.name.trim();
    final idText = value.id?.toString();
    if (rawName.isNotEmpty && rawName != idText) {
      return rawName;
    }
    if (value.id != null) {
      final match = options.firstWhere(
        (item) => item.id == value.id,
        orElse: () => const SellerProductOptionItem(name: ''),
      );
      final matchName = match.name.trim();
      if (matchName.isNotEmpty && matchName != idText) {
        return matchName;
      }
    }
    if (rawName.isNotEmpty) return rawName;
    if (idText != null && idText.isNotEmpty) return idText;
    return '';
  }

  List<SellerProductOptionItem> _attributeValuesFor(
    SellerProductOptionItem attribute,
  ) {
    final rawValues =
        attribute.raw['attribute_values'] ?? attribute.raw['attributeValues'];
    if (rawValues is List) {
      return rawValues
          .map(SellerProductOptionItem.fromJson)
          .where((item) {
            if (item.id == null) return false;
            final status = item.raw['status'];
            if (status is num) return status.toInt() == 1;
            return true;
          })
          .toList();
    }
    return const [];
  }

  void _applyVariationSelectionsFromDetails(SellerProductDetails details) {
    if (details.variations.isEmpty) return;
    final attributeValueIds = <int, Set<int>>{};
    final colorIds = <int>{};

    for (final variation in details.variations) {
      final parts = variation.code.split('/');
      for (final part in parts) {
        final trimmed = part.trim();
        if (trimmed.isEmpty) continue;
        final segments = trimmed.split(':');
        if (segments.length < 2) continue;
        final key = segments[0].trim();
        final valueId = int.tryParse(segments[1].trim());
        if (valueId == null) continue;
        if (key == 'color') {
          colorIds.add(valueId);
        } else {
          final attributeId = int.tryParse(key);
          if (attributeId == null) continue;
          attributeValueIds
              .putIfAbsent(attributeId, () => <int>{})
              .add(valueId);
        }
      }
    }

    final selectedAttributes = _options.attributes
        .where(
          (attribute) =>
              attribute.id != null &&
              attributeValueIds.containsKey(attribute.id),
        )
        .toList()
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

    _selectedAttributes
      ..clear()
      ..addAll(selectedAttributes);
    _selectedAttributeValues.clear();
    for (final attribute in selectedAttributes) {
      final values = _attributeValuesFor(attribute);
      final selected = values
          .where(
            (value) =>
                value.id != null &&
                attributeValueIds[attribute.id]!.contains(value.id),
          )
          .toList();
      if (selected.isNotEmpty) {
        _selectedAttributeValues[attribute.id!] = selected;
      }
    }

    _selectedColors
      ..clear()
      ..addAll(
        _options.colors.where(
          (color) => color.id != null && colorIds.contains(color.id),
        ),
      );
    _useColorVariants = _selectedColors.isNotEmpty;
  }

  void _applyColorVariantImagesFromDetails(SellerProductDetails details) {
    final imagesByColor = details.colorVariantImages;
    if (imagesByColor.isEmpty) return;
    _colorVariantImages.clear();
    for (final entry in imagesByColor.entries) {
      final colorId = entry.key;
      if (!_selectedColors.any((color) => color.id == colorId)) continue;
      final resolved = entry.value
          .map((image) {
            final url = _resolveMediaUrl(image.url) ?? image.url;
            return SellerProductMediaUpload(
              fileId: image.fileId,
              url: url,
              localPath: image.localPath,
            );
          })
          .where((image) => image.fileId > 0 || image.url.isNotEmpty)
          .toList();
      if (resolved.isNotEmpty) {
        _colorVariantImages[colorId] = resolved;
      }
    }
  }

  void _syncColorVariantImagesWithSelection() {
    final selectedIds =
        _selectedColors.map((color) => color.id).whereType<int>().toSet();
    _colorVariantImages.removeWhere((key, _) => !selectedIds.contains(key));
    _colorImageUploading.removeWhere((id) => !selectedIds.contains(id));
  }

  List<SellerProductOptionItem> _matchCategories(List<int> categoryIds) {
    if (categoryIds.isEmpty || _options.categories.isEmpty) {
      return const [];
    }
    final matches = <SellerProductOptionItem>[];
    for (final id in categoryIds) {
      final match = _options.categories.firstWhere(
        (option) => option.id == id,
        orElse: () => const SellerProductOptionItem(name: ''),
      );
      if (match.name.isEmpty) continue;
      if (!_isCategorySelected(match, matches)) {
        matches.add(match);
      }
    }
    return matches;
  }

  bool _isCategorySelected(
    SellerProductOptionItem candidate, [
    List<SellerProductOptionItem>? list,
  ]) {
    final source = list ?? _selectedCategories;
    if (candidate.id != null) {
      return source.any((item) => item.id == candidate.id);
    }
    final name = candidate.name.toLowerCase();
    return source.any((item) => item.name.toLowerCase() == name);
  }

  void _removeCategory(SellerProductOptionItem category) {
    if (category.id != null) {
      _selectedCategories.removeWhere((item) => item.id == category.id);
      return;
    }
    final name = category.name.toLowerCase();
    _selectedCategories
        .removeWhere((item) => item.name.toLowerCase() == name);
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
            sku: variation.sku,
            unitPrice: variation.unitPrice,
            quantity: variation.quantity,
          ),
        ),
      );
  }

  void _syncVariationsFromSelections() {
    if (_productType != 1) return;

    final l10n = AppLocalizations.of(context);
    final combinations =
        _buildVariantCombinations(colorLabel: l10n.addProductPropertyColor);
    final existingByCode = <String, _VariationFormData>{};
    for (final variation in _variations) {
      final code = variation.codeController.text.trim();
      if (code.isNotEmpty) {
        existingByCode[code] = variation;
      }
    }

    final next = <_VariationFormData>[];
    for (final combo in combinations) {
      final existing = existingByCode.remove(combo.code);
      if (existing != null) {
        existing.label = combo.label;
        existing.codeReadOnly = true;
        if (existing.skuController.text.trim().isEmpty) {
          existing.skuController.text = combo.sku;
        }
        if (existing.codeController.text.trim() != combo.code) {
          existing.codeController.text = combo.code;
        }
        next.add(existing);
      } else {
        next.add(
          _VariationFormData(
            code: combo.code,
            sku: combo.sku,
            label: combo.label,
            codeReadOnly: true,
          ),
        );
      }
    }

    for (final leftover in existingByCode.values) {
      leftover.dispose();
    }

    setState(() {
      _variations
        ..clear()
        ..addAll(next);
    });
  }

  List<_VariantCombination> _buildVariantCombinations({
    required String colorLabel,
  }) {
    final attributeIds = _selectedAttributes
        .where((attribute) => attribute.id != null)
        .map((attribute) => attribute.id!)
        .toList()
      ..sort();

    final optionGroups = <_VariantOptionGroup>[];
    for (final attributeId in attributeIds) {
      final values = _selectedAttributeValues[attributeId] ?? const [];
      if (values.isEmpty) continue;
      final attribute = _selectedAttributes.firstWhere(
        (item) => item.id == attributeId,
        orElse: () => const SellerProductOptionItem(name: ''),
      );
      if (attribute.name.isEmpty) continue;
      optionGroups.add(
        _VariantOptionGroup(
          key: attributeId.toString(),
          label: attribute.name,
          values: values..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0)),
        ),
      );
    }

    if (_useColorVariants && _selectedColors.isNotEmpty) {
      final colors = [..._selectedColors]
        ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      optionGroups.add(
        _VariantOptionGroup(
          key: 'color',
          label: colorLabel,
          values: colors,
        ),
      );
    }

    if (optionGroups.isEmpty) {
      return const [];
    }

    var combinations = <Map<String, SellerProductOptionItem>>[
      <String, SellerProductOptionItem>{}
    ];
    for (final group in optionGroups) {
      final next = <Map<String, SellerProductOptionItem>>[];
      for (final combo in combinations) {
        for (final value in group.values) {
          final updated = Map<String, SellerProductOptionItem>.from(combo);
          updated[group.key] = value;
          next.add(updated);
        }
      }
      combinations = next;
    }

    final results = <_VariantCombination>[];
    for (final combo in combinations) {
      final labelParts = <String>[];
      final codeParts = <String>[];
      final skuParts = <String>[];
      for (final group in optionGroups) {
        final value = combo[group.key];
        if (value == null || value.id == null) continue;
        final labelKey = group.label;
        final displayName = group.key == 'color'
            ? _resolveOptionName(value, _options.colors)
            : value.name.trim();
        final safeName = displayName.isNotEmpty
            ? displayName
            : (value.id != null ? value.id.toString() : '');
        labelParts.add('$labelKey: $safeName');
        codeParts.add('${group.key}:${value.id}/');
        if (safeName.isNotEmpty) {
          skuParts.add(safeName);
        }
      }
      results.add(
        _VariantCombination(
          label: labelParts.join(' | '),
          code: codeParts.join(),
          sku: skuParts.isEmpty ? '' : '-${skuParts.join('-')}',
        ),
      );
    }

    return results;
  }

  Future<void> _openCategoryPicker(AppLocalizations l10n) async {
    if (_options.categories.isEmpty) return;
    final initial = _selectedCategories
        .map((category) => category.id)
        .whereType<int>()
        .toSet();
    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final selected = {...initial};
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.addProductCategoryLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: ListView.builder(
                        itemCount: _options.categories.length,
                        itemBuilder: (context, index) {
                          final category = _options.categories[index];
                          final id = category.id;
                          if (id == null) {
                            return const SizedBox.shrink();
                          }
                          final isChecked = selected.contains(id);
                          return CheckboxListTile(
                            value: isChecked,
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  selected.add(id);
                                } else {
                                  selected.remove(id);
                                }
                              });
                            },
                            title: Text(category.name),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.addProductCancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.of(context).pop(selected),
                            child: Text(l10n.editProductSaveAction),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    setState(() {
      _selectedCategories
        ..clear()
        ..addAll(
          _options.categories.where(
            (category) =>
                category.id != null && result.contains(category.id),
          ),
        );
    });
  }

  Future<void> _openColorsPicker(AppLocalizations l10n) async {
    if (_options.colors.isEmpty) return;
    final initial = _selectedColors
        .map((color) => color.id)
        .whereType<int>()
        .toSet();
    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final selected = {...initial};
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.addProductPropertyColor,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: ListView.builder(
                        itemCount: _options.colors.length,
                        itemBuilder: (context, index) {
                          final color = _options.colors[index];
                          final id = color.id;
                          if (id == null) {
                            return const SizedBox.shrink();
                          }
                          final isChecked = selected.contains(id);
                          return CheckboxListTile(
                            value: isChecked,
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  selected.add(id);
                                } else {
                                  selected.remove(id);
                                }
                              });
                            },
                            title: Text(color.name),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.addProductCancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.of(context).pop(selected),
                            child: Text(l10n.editProductSaveAction),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    setState(() {
      _selectedColors
        ..clear()
        ..addAll(
          _options.colors.where(
            (color) => color.id != null && result.contains(color.id),
          ),
        );
      _syncColorVariantImagesWithSelection();
    });
    _syncVariationsFromSelections();
  }

  Future<void> _openAttributeValuesPicker(
    SellerProductOptionItem attribute,
    AppLocalizations l10n,
  ) async {
    final attributeId = attribute.id;
    if (attributeId == null) return;
    final values = _attributeValuesFor(attribute);
    if (values.isEmpty) return;
    final initial = _selectedAttributeValues[attributeId]
            ?.map((value) => value.id)
            .whereType<int>()
            .toSet() ??
        <int>{};

    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final selected = {...initial};
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            attribute.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: ListView.builder(
                        itemCount: values.length,
                        itemBuilder: (context, index) {
                          final value = values[index];
                          final id = value.id;
                          if (id == null) {
                            return const SizedBox.shrink();
                          }
                          final isChecked = selected.contains(id);
                          return CheckboxListTile(
                            value: isChecked,
                            onChanged: (checked) {
                              setModalState(() {
                                if (checked == true) {
                                  selected.add(id);
                                } else {
                                  selected.remove(id);
                                }
                              });
                            },
                            title: Text(value.name),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.addProductCancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.of(context).pop(selected),
                            child: Text(l10n.editProductSaveAction),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    setState(() {
      _selectedAttributeValues[attributeId] =
          values.where((value) => value.id != null && result.contains(value.id)).toList();
    });
    _syncVariationsFromSelections();
  }

  void _addAttribute(SellerProductOptionItem attribute) {
    if (attribute.id == null) return;
    if (_selectedAttributes.any((item) => item.id == attribute.id)) return;
    setState(() {
      _selectedAttributes.add(attribute);
    });
    _syncVariationsFromSelections();
  }

  void _removeAttribute(SellerProductOptionItem attribute) {
    final id = attribute.id;
    if (id == null) return;
    setState(() {
      _selectedAttributes.removeWhere((item) => item.id == id);
      _selectedAttributeValues.remove(id);
    });
    _syncVariationsFromSelections();
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

  Future<void> _saveDraft() async {
    if (_isSaving) return;
    setState(() {
      _publishNow = false;
    });
    await _saveProduct();
  }

  Future<void> _saveProduct() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    final isDraft = !_publishNow;
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

    if (!isDraft && _productType == 1 && _variations.isEmpty) {
      showAppSnackBar(context, l10n.productsFormVariationRequired);
      return;
    }

    final categoryIds = _selectedCategories
        .map((category) => category.id)
        .whereType<int>()
        .toList();
    if (!isDraft && categoryIds.isEmpty && _options.categories.isNotEmpty) {
      showAppSnackBar(context, l10n.productsFormCategoryRequired);
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
    if (widget.productId != null) {
      payload['id'] = widget.productId;
    }

    final unitValue = _selectedUnit?.id ?? _selectedUnit?.name;
    if (unitValue != null) {
      payload['unit'] = unitValue;
    }

    final conditionValue = _selectedCondition?.id ?? _selectedCondition?.name;
    if (conditionValue != null) {
      payload['condition'] = conditionValue;
    }

    if (categoryIds.isNotEmpty) {
      payload['categories'] = categoryIds;
    }

    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) {
      payload['description'] = description;
    }

    if (_thumbnailFileId != null) {
      payload['thumbnail_image'] = _thumbnailFileId;
    }
    final galleryIds = _galleryImages
        .map((image) => image.fileId)
        .where((id) => id > 0)
        .toSet()
        .toList();
    if (galleryIds.isNotEmpty) {
      payload['gallery_images'] = galleryIds.join(',');
    }

    if (_productType == 1 && _useColorVariants && _selectedColors.isNotEmpty) {
      final colorIds = _selectedColors
          .map((color) => color.id)
          .whereType<int>()
          .toList();
      if (colorIds.isNotEmpty) {
        payload['selected_colors'] = colorIds;
        for (final colorId in colorIds) {
          final images =
              _colorVariantImages[colorId] ?? const <SellerProductMediaUpload>[];
          final imageIds = images
              .map((image) => image.fileId)
              .where((id) => id > 0)
              .toList();
          if (imageIds.isNotEmpty) {
            payload['color_${colorId}_image'] = imageIds.join(',');
          }
        }
      }
    }

    if (_productType == 1) {
      final variationsPayload = _variations
          .map((variation) => variation.toPayload())
          .where((item) => item.isNotEmpty)
          .toList();
      if (variationsPayload.isEmpty) {
        if (!isDraft) {
          showAppSnackBar(context, l10n.productsFormVariationRequired);
          return;
        }
      } else {
        payload['variations'] = variationsPayload;
      }
    } else {
      final unitPrice =
          double.tryParse(_unitPriceController.text.trim()) ?? 0;
      payload['unit_price'] = unitPrice;
      payload['purchase_price'] = unitPrice;
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
      Navigator.of(context).pop(ProductFormResult.saved(isDraft: isDraft));
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

  Future<void> _pickGalleryImages() async {
    if (_isGalleryUploading) return;
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    try {
      final picked = await _imagePicker.pickMultiImage();
      final files = <File>[];
      if (picked.isEmpty) {
        final single = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        if (single != null) {
          files.add(File(single.path));
        }
      } else {
        files.addAll(picked.map((item) => File(item.path)));
      }
      if (files.isEmpty) return;

      final validFiles = <File>[];
      for (final file in files) {
        final size = await file.length();
        if (size > 4 * 1024 * 1024) {
          showAppSnackBar(context, l10n.productsImageTooLarge);
          continue;
        }
        validFiles.add(file);
      }
      if (validFiles.isEmpty) return;

      setState(() => _isGalleryUploading = true);
      final uploads = await _productsService.uploadProductMediaBatch(
        authToken: token,
        files: validFiles,
        productId: widget.productId,
      );
      if (!mounted) return;
      if (uploads.isEmpty) {
        showAppSnackBar(context, l10n.productsImageUploadFailed);
        return;
      }
      final resolvedUploads = _resolveGalleryUploads(uploads);
      setState(() {
        final existingIds =
            _galleryImages.map((item) => item.fileId).toSet();
        for (final upload in resolvedUploads) {
          if (upload.fileId > 0 && existingIds.contains(upload.fileId)) {
            continue;
          }
          _galleryImages.add(upload);
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Upload gallery images failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        showAppSnackBar(
          context,
          _errorMessage(e, l10n.productsImageUploadFailed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGalleryUploading = false);
      }
    }
  }

  void _removeGalleryImage(SellerProductMediaUpload image) {
    setState(() {
      _galleryImages.removeWhere(
        (item) => item.fileId == image.fileId && item.url == image.url,
      );
    });
  }

  Future<void> _pickColorVariantImages(SellerProductOptionItem color) async {
    final colorId = color.id;
    if (colorId == null) return;
    if (_colorImageUploading.contains(colorId)) return;
    final l10n = AppLocalizations.of(context);
    final token = _authToken;
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    try {
      final picked = await _imagePicker.pickMultiImage();
      final files = <File>[];
      if (picked.isEmpty) {
        final single = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        if (single != null) {
          files.add(File(single.path));
        }
      } else {
        files.addAll(picked.map((item) => File(item.path)));
      }
      if (files.isEmpty) return;

      final validFiles = <File>[];
      for (final file in files) {
        final size = await file.length();
        if (size > 4 * 1024 * 1024) {
          showAppSnackBar(context, l10n.productsImageTooLarge);
          continue;
        }
        validFiles.add(file);
      }
      if (validFiles.isEmpty) return;

      setState(() {
        _colorImageUploading.add(colorId);
      });

      final uploads = await _productsService.uploadProductMediaBatch(
        authToken: token,
        files: validFiles,
        productId: widget.productId,
      );
      if (!mounted) return;
      if (uploads.isEmpty) {
        showAppSnackBar(context, l10n.productsImageUploadFailed);
        return;
      }
      final resolvedUploads = uploads.map((upload) {
        final url = _resolveMediaUrl(upload.url) ?? upload.url;
        return SellerProductMediaUpload(
          fileId: upload.fileId,
          url: url,
          localPath: upload.localPath,
        );
      }).toList();
      setState(() {
        final existing = _colorVariantImages[colorId] ?? <SellerProductMediaUpload>[];
        _colorVariantImages[colorId] = [...existing, ...resolvedUploads];
      });
    } catch (e, stackTrace) {
      debugPrint('Upload color images failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        showAppSnackBar(context, _errorMessage(e, l10n.productsImageUploadFailed));
      }
    } finally {
      if (mounted) {
        setState(() {
          _colorImageUploading.remove(colorId);
        });
      }
    }
  }

  void _removeColorVariantImage(int colorId, SellerProductMediaUpload image) {
    setState(() {
      final images = _colorVariantImages[colorId];
      if (images == null) return;
      images.removeWhere((item) => item.fileId == image.fileId && item.url == image.url);
      if (images.isEmpty) {
        _colorVariantImages.remove(colorId);
      }
    });
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
        ? (isEditing
            ? l10n.editProductSaveAction
            : (_publishNow ? l10n.addProductPublish : l10n.addProductSaveDraft))
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
    final categoryChildren = <Widget>[
      InkWell(
        onTap: _options.categories.isEmpty ? null : () => _openCategoryPicker(l10n),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: l10n.addProductCategoryLabel,
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          child: Text(
            _selectedCategories.isEmpty
                ? l10n.addProductCategoryLabel
                : _selectedCategories.map((c) => c.name).join(', '),
            style: _selectedCategories.isEmpty
                ? theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)
                : theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];
    if (_selectedCategories.isNotEmpty) {
      categoryChildren.add(const SizedBox(height: 12));
      categoryChildren.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedCategories
              .map(
                (category) => InputChip(
                  label: Text(category.name),
                  onDeleted: () {
                    setState(() {
                      _removeCategory(category);
                    });
                  },
                ),
              )
              .toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionHeader(
          title: l10n.addProductBasicsTitle,
          subtitle: l10n.addProductBasicsSubtitle,
        ),
        const SizedBox(height: 16),
        _buildCardSection(
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.addProductNameLabel),
            ),
            TextFormField(
              controller: _permalinkController,
              onChanged: (_) {
                if (_syncingPermalink) return;
                _permalinkDirty = true;
              },
              decoration: InputDecoration(labelText: l10n.productsPermalinkLabel),
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.addProductDescriptionLabel,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCardSection(
          children: [
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
                });
                if (_productType == 1) {
                  _syncVariationsFromSelections();
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<SellerProductOptionItem>(
                    initialValue: _selectedUnit,
                    isExpanded: true,
                    decoration:
                        InputDecoration(labelText: l10n.addProductUnitLabel),
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
          ],
        ),
        const SizedBox(height: 16),
        _buildCardSection(children: categoryChildren),
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
          _buildCardSection(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitPriceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.productsSellingPriceLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.productsQuantityLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ] else ...[
          Text(
            l10n.addProductVariationOptionsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.addProductVariationOptionsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildCardSection(
            children: [
              SwitchListTile.adaptive(
                value: _useColorVariants,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.addProductColorVariantsLabel),
                onChanged: (value) {
                  setState(() {
                    _useColorVariants = value;
                    if (!_useColorVariants) {
                      _selectedColors.clear();
                      _colorVariantImages.clear();
                      _colorImageUploading.clear();
                    }
                  });
                  _syncVariationsFromSelections();
                },
              ),
              if (_useColorVariants) ...[
                InkWell(
                  onTap: () => _openColorsPicker(l10n),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.addProductPropertyColor,
                      suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                    child: Text(
                      _selectedColors.isEmpty
                          ? l10n.addProductSelectColorsAction
                          : _selectedColors.map((c) => c.name).join(', '),
                      style: _selectedColors.isEmpty
                          ? theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.hintColor)
                          : theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (_selectedColors.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedColors
                        .map(
                          (color) => InputChip(
                            label: Text(color.name),
                            onDeleted: () {
                              setState(() {
                                _selectedColors.removeWhere(
                                  (item) => item.id == color.id,
                                );
                                if (color.id != null) {
                                  _colorVariantImages.remove(color.id);
                                  _colorImageUploading.remove(color.id);
                                }
                              });
                              _syncVariationsFromSelections();
                            },
                          ),
                        )
                        .toList(),
                  ),
              ],
              DropdownButtonFormField<SellerProductOptionItem>(
                key: ValueKey(
                  _selectedAttributes.map((attribute) => attribute.id).join(','),
                ),
                initialValue: null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.addProductSelectAttributesLabel,
                ),
                items: _options.attributes
                    .where((attribute) => attribute.id != null)
                    .where(
                      (attribute) => !_selectedAttributes.any(
                        (selected) => selected.id == attribute.id,
                      ),
                    )
                    .map(
                      (attribute) => DropdownMenuItem(
                        value: attribute,
                        child: Text(
                          attribute.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  _addAttribute(value);
                },
              ),
              if (_selectedAttributes.isNotEmpty)
                ..._selectedAttributes.map((attribute) {
                  final selectedValues =
                      _selectedAttributeValues[attribute.id] ?? const [];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kSurfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBrandColor.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                attribute.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeAttribute(attribute),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () =>
                              _openAttributeValuesPicker(attribute, l10n),
                          child: Text(l10n.addProductSelectValuesAction),
                        ),
                        if (selectedValues.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedValues
                                .map(
                                  (value) => InputChip(
                                    label: Text(value.name),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedAttributeValues[attribute.id!]
                                            ?.removeWhere(
                                          (item) => item.id == value.id,
                                        );
                                      });
                                      _syncVariationsFromSelections();
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
          const SizedBox(height: 16),
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
                    Text(
                      variation.label?.isNotEmpty == true
                          ? variation.label!
                          : l10n.productsVariationLabel(index + 1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: variation.codeController,
                            readOnly: variation.codeReadOnly,
                            decoration: InputDecoration(
                              labelText: l10n.productsVariationCodeLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: variation.skuController,
                            decoration: InputDecoration(
                              labelText: l10n.addProductSkuLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: variation.unitPriceController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.productsSellingPriceLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: variation.quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.productsQuantityLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_variations.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.productsVariationsEmpty,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ],
        ],
        const SizedBox(height: 24),
        _buildCardSection(
          children: [
            DropdownButtonFormField<int>(
              initialValue: _discountType,
              isExpanded: true,
              decoration:
                  InputDecoration(labelText: l10n.productsDiscountTypeLabel),
              items: [
                DropdownMenuItem(
                  value: 2,
                  child: Text(l10n.productsDiscountTypeFixed),
                ),
                DropdownMenuItem(
                  value: 1,
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
            TextFormField(
              controller: _discountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: l10n.productsDiscountAmountLabel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorVariantImagesSection(
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (_productType != 1 || !_useColorVariants) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.addProductColorImagesTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.addProductColorImagesSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedColors.isEmpty)
          Text(
            l10n.addProductColorImagesEmpty,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          )
        else
          ..._selectedColors.map((color) {
            final colorId = color.id;
            final colorName = color.name.trim();
            final colorLabel = colorName.isNotEmpty
                ? colorName
                : (colorId != null
                    ? '${l10n.addProductPropertyColor} #$colorId'
                    : l10n.addProductPropertyColor);
            final images = colorId == null
                ? const <SellerProductMediaUpload>[]
                : (_colorVariantImages[colorId] ??
                    const <SellerProductMediaUpload>[]);
            final isUploading =
                colorId != null && _colorImageUploading.contains(colorId);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                          colorLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: (colorId == null || isUploading)
                            ? null
                            : () => _pickColorVariantImages(color),
                        icon: isUploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(l10n.addProductColorImagesAdd),
                      ),
                    ],
                  ),
                  if (images.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.addProductColorImagesNone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: images.map((image) {
                        final url = _resolveMediaUrl(image.url) ?? image.url;
                        return _ColorImageTile(
                          imageUrl: url,
                          onRemove: () {
                            if (colorId == null) return;
                            _removeColorVariantImage(colorId, image);
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildCardSection({
    required List<Widget> children,
  }) {
    final content = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      content.add(children[i]);
      if (i != children.length - 1) {
        content.add(const SizedBox(height: 16));
      }
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBrandColor.withOpacity(0.08)),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
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
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.addProductImagesTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _isGalleryUploading ? null : _pickGalleryImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(l10n.addProductImagesAdd),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isGalleryUploading)
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.addProductMediaUploadInProgress,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        if (!_isGalleryUploading && _galleryImages.isEmpty)
          Text(
            l10n.addProductMediaUploadReady,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
        if (_galleryImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _galleryImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final image = _galleryImages[index];
              final url = _resolveMediaUrl(image.url) ?? image.url;
              return _GalleryImageTile(
                imageUrl: url,
                onRemove: () => _removeGalleryImage(image),
              );
            },
          ),
        if (_productType == 1 && _useColorVariants) ...[
          const SizedBox(height: 20),
          _buildColorVariantImagesSection(theme, l10n),
        ],
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
  final bool isDraft;

  const ProductFormResult.saved({this.isDraft = false})
      : action = ProductFormAction.saved;
  const ProductFormResult.deleted()
      : action = ProductFormAction.deleted,
        isDraft = false;
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
  final TextEditingController skuController;
  final TextEditingController unitPriceController;
  final TextEditingController quantityController;
  String? label;
  bool codeReadOnly;

  _VariationFormData({
    this.id,
    String? code,
    String? sku,
    double? unitPrice,
    int? quantity,
    this.label,
    this.codeReadOnly = false,
  })  : codeController = TextEditingController(text: code ?? ''),
        skuController = TextEditingController(text: sku ?? ''),
        unitPriceController =
            TextEditingController(text: unitPrice?.toString() ?? ''),
        quantityController =
            TextEditingController(text: quantity?.toString() ?? '');

  Map<String, dynamic> toPayload() {
    final code = codeController.text.trim();
    if (code.isEmpty) return const <String, dynamic>{};
    final unitPrice = double.tryParse(unitPriceController.text.trim()) ?? 0;
    final payload = <String, dynamic>{
      'code': code,
      'sku': skuController.text.trim(),
      'unit_price': unitPrice,
      'purchase_price': unitPrice,
      'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
    };
    if (id != null) {
      payload['id'] = id;
    }
    return payload;
  }

  void dispose() {
    codeController.dispose();
    skuController.dispose();
    unitPriceController.dispose();
    quantityController.dispose();
  }
}

class _VariantOptionGroup {
  final String key;
  final String label;
  final List<SellerProductOptionItem> values;

  const _VariantOptionGroup({
    required this.key,
    required this.label,
    required this.values,
  });
}

class _VariantCombination {
  final String label;
  final String code;
  final String sku;

  const _VariantCombination({
    required this.label,
    required this.code,
    required this.sku,
  });
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

class _GalleryImageTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onRemove;

  const _GalleryImageTile({
    required this.imageUrl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBrandColor.withOpacity(0.15)),
            boxShadow: kSoftShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  )
                : const Icon(Icons.image_not_supported_outlined),
          ),
        ),
        PositionedDirectional(
          top: 6,
          end: 6,
          child: InkResponse(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: kSoftShadow,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: kInkColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorImageTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onRemove;

  const _ColorImageTile({
    required this.imageUrl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 72,
            height: 72,
            color: kSurfaceColor,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  )
                : const Icon(Icons.image_not_supported_outlined),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: Colors.black54,
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}
