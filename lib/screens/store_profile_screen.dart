import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_navigation.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../config/api_config.dart';
import '../services/auth_storage.dart';
import '../services/seller_auth_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/form_section_header.dart';
import '../widgets/labeled_switch_row.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';

class StoreProfileScreen extends StatefulWidget {
  static const String routeName = AppRoutes.storeProfile;

  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _metaTitleController = TextEditingController();
  final TextEditingController _metaDescriptionController = TextEditingController();
  final TextEditingController _sellerPhoneController = TextEditingController();
  final TextEditingController _shopPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final SellerAuthService _sellerAuthService = SellerAuthService();
  final AuthStorage _authStorage = AuthStorage();
  final ImagePicker _imagePicker = ImagePicker();

  bool _storeOpen = true;
  bool _pickupEnabled = true;
  bool _deliveryEnabled = true;
  bool _isLoadingProfile = false;
  bool _isSaving = false;
  bool _isUpdatingLogo = false;
  bool _isUpdatingBanner = false;
  bool _isUpdatingMetaImage = false;
  String? _logoUrl;
  String? _bannerUrl;
  String? _metaImageUrl;
  String _selectedCategory = _categoryKeys.first;
  String _selectedPrepTime = _prepTimeKeys.first;

  static const List<String> _categoryKeys = [
    'skincare',
    'fragrance',
    'beauty',
    'accessories',
  ];

  static const List<String> _prepTimeKeys = [
    'same_day',
    '1_2_days',
    '3_5_days',
  ];

  String _categoryLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'skincare':
        return l10n.storeProfileCategorySkincare;
      case 'fragrance':
        return l10n.storeProfileCategoryFragrance;
      case 'beauty':
        return l10n.storeProfileCategoryBeauty;
      case 'accessories':
        return l10n.storeProfileCategoryAccessories;
    }
    return key;
  }

  String _prepTimeLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'same_day':
        return l10n.storeProfilePrepSameDay;
      case '1_2_days':
        return l10n.storeProfilePrep1to2Days;
      case '3_5_days':
        return l10n.storeProfilePrep3to5Days;
    }
    return key;
  }

  List<_StoreHour> _buildStoreHours(AppLocalizations l10n) {
    return [
      _StoreHour(
        day: l10n.storeProfileDayMon,
        hours: l10n.storeProfileHoursRegular,
      ),
      _StoreHour(
        day: l10n.storeProfileDayTue,
        hours: l10n.storeProfileHoursRegular,
      ),
      _StoreHour(
        day: l10n.storeProfileDayWed,
        hours: l10n.storeProfileHoursRegular,
      ),
      _StoreHour(
        day: l10n.storeProfileDayThu,
        hours: l10n.storeProfileHoursLate,
      ),
      _StoreHour(
        day: l10n.storeProfileDayFri,
        hours: l10n.storeProfileHoursFriday,
      ),
      _StoreHour(
        day: l10n.storeProfileDaySat,
        hours: l10n.storeProfileHoursWeekend,
      ),
      _StoreHour(
        day: l10n.storeProfileDaySun,
        hours: l10n.storeProfileHoursClosed,
      ),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _metaTitleController.dispose();
    _metaDescriptionController.dispose();
    _sellerPhoneController.dispose();
    _shopPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final l10n = AppLocalizations.of(context);
    final token = await _authStorage.readToken();
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    setState(() => _isLoadingProfile = true);
    try {
      final response =
          await _sellerAuthService.fetchSellerShopDetails(authToken: token);
      final success = response['success'] == true;
      final details =
          response['details'] is Map ? response['details'] as Map : null;
      if (!mounted) return;
      if (!success) {
        setState(_clearProfileFields);
        return;
      }
      if (details == null) {
        debugPrint(
          'Load shop profile failed: missing details in response: $response',
        );
        showAppSnackBar(context, l10n.storeProfileLoadFailed);
        return;
      }

      setState(() {
        _nameController.text = details['name']?.toString() ?? '';
        _slugController.text = details['slug']?.toString() ?? '';
        _shopPhoneController.text = details['shop_phone']?.toString() ?? '';
        _sellerPhoneController.text =
            details['seller_phone']?.toString() ?? '';
        _addressController.text = details['shop_address']?.toString() ?? '';
        _metaTitleController.text = details['meta_title']?.toString() ?? '';
        _metaDescriptionController.text =
            details['meta_description']?.toString() ?? '';
        _metaImageUrl = _cacheBust(
          _resolveMediaUrl(
            details['meta_image_url']?.toString() ??
                details['meta_image']?.toString(),
          ),
        );
        _logoUrl = _cacheBust(
          _resolveMediaUrl(
            details['logo']?.toString() ?? details['shop_logo']?.toString(),
          ),
        );
        _bannerUrl = _cacheBust(
          _resolveMediaUrl(details['shop_banner']?.toString()),
        );
      });
    } catch (e, stackTrace) {
      if (mounted) {
        if (_isUnauthenticatedError(e)) {
          await _handleUnauthenticated(l10n);
          return;
        }
        debugPrint('Load shop profile failed: $e');
        debugPrintStack(stackTrace: stackTrace);
        setState(_clearProfileFields);
        showAppSnackBar(
          context,
          _profileErrorMessage(e, l10n.storeProfileLoadFailed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context);
    final token = await _authStorage.readToken();
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    final shopName = _nameController.text.trim();
    final shopPhone = _shopPhoneController.text.trim();
    final shopSlug = _slugController.text.trim();

    if (shopName.isEmpty) {
      if (mounted) {
        showAppSnackBar(context, l10n.storeProfileNameRequired);
      }
      return;
    }
    if (shopPhone.isEmpty) {
      if (mounted) {
        showAppSnackBar(context, l10n.storeProfileShopPhoneRequired);
      }
      return;
    }
    if (shopSlug.isEmpty) {
      if (mounted) {
        showAppSnackBar(context, l10n.storeProfileSlugRequired);
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      final response = await _sellerAuthService.updateSellerShopDetails(
        authToken: token,
        shopName: shopName,
        shopPhone: shopPhone,
        shopSlug: shopSlug,
        sellerPhone: _sellerPhoneController.text.trim(),
        shopAddress: _addressController.text.trim(),
      );
      final success = response['success'] == true;
      final details =
          response['details'] is Map ? response['details'] as Map : null;
      if (!mounted) return;
      if (!success || details == null) {
        showAppSnackBar(context, l10n.storeProfileUpdateFailed);
        return;
      }
      setState(() {
        _nameController.text = details['name']?.toString() ?? shopName;
        _slugController.text = details['slug']?.toString() ?? shopSlug;
        _shopPhoneController.text =
            details['shop_phone']?.toString() ?? shopPhone;
        if (details['seller_phone'] != null) {
          _sellerPhoneController.text =
              details['seller_phone']?.toString() ?? _sellerPhoneController.text;
        }
        if (details['meta_title'] != null) {
          _metaTitleController.text =
              details['meta_title']?.toString() ?? _metaTitleController.text;
        }
        if (details['meta_description'] != null) {
          _metaDescriptionController.text =
              details['meta_description']?.toString() ??
                  _metaDescriptionController.text;
        }
        _addressController.text =
            details['shop_address']?.toString() ?? _addressController.text;
        _logoUrl =
            details['logo']?.toString() ?? details['shop_logo']?.toString() ?? _logoUrl;
        _bannerUrl = details['shop_banner']?.toString() ?? _bannerUrl;
      });
      await _updateSeoDetails(token, l10n);
      if (!mounted) return;
      showAppSnackBar(context, l10n.storeProfileSavedMessage);
    } catch (e, stackTrace) {
      if (mounted) {
        if (_isUnauthenticatedError(e)) {
          await _handleUnauthenticated(l10n);
          return;
        }
        debugPrint('Update shop profile failed: $e');
        debugPrintStack(stackTrace: stackTrace);
        showAppSnackBar(
          context,
          _profileErrorMessage(e, l10n.storeProfileUpdateFailed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _previewStore() {
    final l10n = AppLocalizations.of(context);
    showAppSnackBar(context, l10n.storeProfilePreviewMessage);
  }

  Future<void> _pickAndUpdateImage(String type) async {
    final l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      showAppSnackBar(context, l10n.storeProfileImagePickFailed);
      return;
    }

    final token = await _authStorage.readToken();
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) return;

      final size = await picked.length();
      if (size > 4 * 1024 * 1024) {
        if (!mounted) return;
        showAppSnackBar(context, l10n.storeProfileImageTooLarge);
        return;
      }

      setState(() {
        if (type == 'logo') {
          _isUpdatingLogo = true;
        } else {
          _isUpdatingBanner = true;
        }
      });

      final response = await _sellerAuthService.updateSellerShopImage(
        authToken: token,
        type: type,
        imageFile: File(picked.path),
      );
      if (!mounted) return;

      final details =
          response['details'] is Map ? response['details'] as Map : null;
      final rawUrl = response['url']?.toString();
      final resolvedUrl = _cacheBust(_resolveMediaUrl(rawUrl));
      setState(() {
        if (type == 'logo') {
          _logoUrl = resolvedUrl ??
              _resolveMediaUrl(
                details?['logo']?.toString() ??
                    details?['shop_logo']?.toString(),
              ) ??
              _logoUrl;
        } else {
          _bannerUrl = resolvedUrl ??
              _resolveMediaUrl(details?['shop_banner']?.toString()) ??
              _bannerUrl;
        }
      });
      showAppSnackBar(context, l10n.storeProfileImageUpdatedMessage);
    } catch (e, stackTrace) {
      if (mounted) {
        if (_isUnauthenticatedError(e)) {
          await _handleUnauthenticated(l10n);
          return;
        }
        debugPrint('Update shop image failed: $e');
        debugPrintStack(stackTrace: stackTrace);
        showAppSnackBar(
          context,
          _profileErrorMessage(e, l10n.storeProfileImageUpdateFailed),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingLogo = false;
          _isUpdatingBanner = false;
        });
      }
    }
  }

  Future<void> _pickAndUpdateSeoImage() async {
    final l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      showAppSnackBar(context, l10n.storeProfileImagePickFailed);
      return;
    }

    final token = await _authStorage.readToken();
    if (token == null || token.isEmpty) {
      await _handleUnauthenticated(l10n);
      return;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) return;

      final size = await picked.length();
      if (size > 4 * 1024 * 1024) {
        if (!mounted) return;
        showAppSnackBar(context, l10n.storeProfileImageTooLarge);
        return;
      }

      setState(() => _isUpdatingMetaImage = true);
      final response = await _sellerAuthService.updateSellerShopSeo(
        authToken: token,
        imageFile: File(picked.path),
      );
      if (!mounted) return;

      final rawUrl = response['meta_image_url']?.toString();
      final resolvedUrl = _cacheBust(_resolveMediaUrl(rawUrl));
      setState(() {
        _metaImageUrl = resolvedUrl ?? _metaImageUrl;
      });
      showAppSnackBar(context, l10n.storeProfileImageUpdatedMessage);
    } catch (e, stackTrace) {
      if (mounted) {
        if (_isUnauthenticatedError(e)) {
          await _handleUnauthenticated(l10n);
          return;
        }
        debugPrint('Update shop SEO image failed: $e');
        debugPrintStack(stackTrace: stackTrace);
        showAppSnackBar(
          context,
          _profileErrorMessage(e, l10n.storeProfileImageUpdateFailed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingMetaImage = false);
      }
    }
  }

  Future<void> _updateSeoDetails(String token, AppLocalizations l10n) async {
    final metaTitle = _metaTitleController.text.trim();
    final metaDescription = _metaDescriptionController.text.trim();
    if (metaTitle.isEmpty && metaDescription.isEmpty) {
      return;
    }

    try {
      final response = await _sellerAuthService.updateSellerShopSeo(
        authToken: token,
        metaTitle: metaTitle.isEmpty ? null : metaTitle,
        metaDescription: metaDescription.isEmpty ? null : metaDescription,
      );
      if (!mounted) return;

      final details =
          response['details'] is Map ? response['details'] as Map : null;
      final rawUrl = response['meta_image_url']?.toString() ??
          details?['meta_image_url']?.toString() ??
          details?['meta_image']?.toString();
      final resolvedUrl = _cacheBust(_resolveMediaUrl(rawUrl));
      setState(() {
        _metaTitleController.text = details?['meta_title']?.toString() ?? metaTitle;
        _metaDescriptionController.text =
            details?['meta_description']?.toString() ?? metaDescription;
        _metaImageUrl = resolvedUrl ?? _metaImageUrl;
      });
    } catch (e, stackTrace) {
      if (_isUnauthenticatedError(e)) {
        await _handleUnauthenticated(l10n);
        return;
      }
      debugPrint('Update shop SEO failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        showAppSnackBar(context, l10n.storeProfileUpdateFailed);
      }
    }
  }

  Future<void> _handleUnauthenticated(AppLocalizations l10n) async {
    await _authStorage.clearToken();
    if (!mounted) return;
    setState(_clearProfileFields);
    showAppSnackBar(context, l10n.storeProfileAuthRequired);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _clearProfileFields() {
    _nameController.clear();
    _slugController.clear();
    _shopPhoneController.clear();
    _sellerPhoneController.clear();
    _addressController.clear();
    _metaTitleController.clear();
    _metaDescriptionController.clear();
    _logoUrl = null;
    _bannerUrl = null;
    _metaImageUrl = null;
  }

  bool _isUnauthenticatedError(Object error) {
    return error.toString().contains('Unauthenticated');
  }

  String? _cacheBust(String? url) {
    if (url == null || url.isEmpty) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=${DateTime.now().millisecondsSinceEpoch}';
  }

  String? _resolveMediaUrl(String? path) {
    final resolved = ApiConfig.resolveMediaUrl(path);
    return resolved.isEmpty ? null : resolved;
  }

  String _profileErrorMessage(Object error, String fallback) {
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
    final hours = _buildStoreHours(l10n);

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
              if (_isLoadingProfile)
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
                  child: LinearProgressIndicator(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: FormSectionHeader(
                  title: l10n.storeProfileTitle,
                  subtitle: l10n.storeProfileSubtitle,
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
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: kBrandColor.withOpacity(0.12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: _logoUrl != null && _logoUrl!.isNotEmpty
                                  ? Image.network(
                                      _logoUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/branding/majdoleen_logo.png',
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/branding/majdoleen_logo.png',
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.storeProfileLogoTitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.storeProfileLogoHint,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: kInkColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: _isUpdatingLogo
                                ? null
                                : () => _pickAndUpdateImage('logo'),
                            child: _isUpdatingLogo
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(l10n.storeProfileLogoUpdateAction),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: kSurfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: kBrandColor.withOpacity(0.1),
                          ),
                        ),
                        child: _bannerUrl != null && _bannerUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  _bannerUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        l10n.storeProfileBannerLabel,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: kInkColor.withOpacity(0.6),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Text(
                                  l10n.storeProfileBannerLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: kInkColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OutlinedButton(
                          onPressed: _isUpdatingBanner
                              ? null
                              : () => _pickAndUpdateImage('banner'),
                          child: _isUpdatingBanner
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.storeProfileBannerUpdateAction),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.storeProfileDetailsTitle,
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
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            InputDecoration(
                              labelText: l10n.storeProfileNameLabel,
                              hintText: l10n.storeProfileNameHint,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _slugController,
                        decoration:
                            InputDecoration(
                              labelText: l10n.storeProfileSlugLabel,
                              hintText: l10n.storeProfileSlugHint,
                            ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        items: _categoryKeys
                            .map(
                              (categoryKey) => DropdownMenuItem(
                                value: categoryKey,
                                child: Text(_categoryLabel(l10n, categoryKey)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: l10n.storeProfileCategoryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.storeProfileContactTitle,
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
                      TextFormField(
                        controller: _sellerPhoneController,
                        decoration:
                            InputDecoration(
                              labelText: l10n.storeProfileSellerPhoneLabel,
                              hintText: l10n.storeProfileSellerPhoneHint,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _shopPhoneController,
                        decoration:
                            InputDecoration(
                              labelText: l10n.storeProfileShopPhoneLabel,
                              hintText: l10n.storeProfileShopPhoneHint,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration:
                            InputDecoration(
                              labelText: l10n.storeProfileAddressLabel,
                              hintText: l10n.storeProfileAddressHint,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.storeProfileSeoTitle,
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
                      TextFormField(
                        controller: _metaTitleController,
                        decoration: InputDecoration(
                          labelText: l10n.storeProfileMetaTitleLabel,
                          hintText: l10n.storeProfileMetaTitleHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _metaDescriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.storeProfileMetaDescriptionLabel,
                          hintText: l10n.storeProfileMetaDescriptionHint,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.storeProfileMetaImageLabel,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: _isUpdatingMetaImage
                                ? null
                                : _pickAndUpdateSeoImage,
                            child: _isUpdatingMetaImage
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(l10n.storeProfileMetaImageUpdateAction),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: kSurfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: kBrandColor.withOpacity(0.1),
                          ),
                        ),
                        child: _metaImageUrl != null && _metaImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  _metaImageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        l10n.storeProfileMetaImageLabel,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: kInkColor.withOpacity(0.6),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Text(
                                  l10n.storeProfileMetaImageLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: kInkColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.storeProfileStatusTitle,
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
                      LabeledSwitchRow(
                        title: l10n.storeProfileStatusOpenTitle,
                        subtitle: l10n.storeProfileStatusOpenSubtitle,
                        value: _storeOpen,
                        onChanged: (value) {
                          setState(() {
                            _storeOpen = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.storeProfileFulfillmentTitle,
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
                      LabeledSwitchRow(
                        title: l10n.storeProfilePickupTitle,
                        subtitle: l10n.storeProfilePickupSubtitle,
                        value: _pickupEnabled,
                        onChanged: (value) {
                          setState(() {
                            _pickupEnabled = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      LabeledSwitchRow(
                        title: l10n.storeProfileDeliveryTitle,
                        subtitle: l10n.storeProfileDeliverySubtitle,
                        value: _deliveryEnabled,
                        onChanged: (value) {
                          setState(() {
                            _deliveryEnabled = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPrepTime,
                        items: _prepTimeKeys
                            .map(
                              (timeKey) => DropdownMenuItem(
                                value: timeKey,
                                child: Text(_prepTimeLabel(l10n, timeKey)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedPrepTime = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: l10n.storeProfilePrepTimeLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.storeProfileBusinessHoursTitle,
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
                    children: hours
                        .map(
                          (hour) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StoreHourRow(hour),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previewStore,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: kBrandColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(l10n.storeProfilePreviewAction),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: Text(l10n.storeProfileSaveAction),
                      ),
                    ),
                  ],
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

class _StoreHour {
  final String day;
  final String hours;

  const _StoreHour({
    required this.day,
    required this.hours,
  });
}

class _StoreHourRow extends StatelessWidget {
  final _StoreHour hour;

  const _StoreHourRow(this.hour);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 46,
          height: 40,
          decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              hour.day,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: kInkColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            hour.hours,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: kInkColor.withOpacity(0.7),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined),
          color: kBrandColor,
        ),
      ],
    );
  }
}
