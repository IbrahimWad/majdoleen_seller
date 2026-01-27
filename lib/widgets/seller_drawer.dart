import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../services/auth_storage.dart';
import '../services/seller_auth_service.dart';
import 'app_snackbar.dart';

class SellerDrawer extends StatefulWidget {
  const SellerDrawer({super.key});

  @override
  State<SellerDrawer> createState() => _SellerDrawerState();
}

class _SellerDrawerState extends State<SellerDrawer> {
  final AuthStorage _authStorage = AuthStorage();
  final SellerAuthService _authService = const SellerAuthService();

  String? _shopName;
  String? _shopPhone;
  String? _shopSlug;
  String? _shopLogoUrl;
  int? _shopStatus;

  @override
  void initState() {
    super.initState();
    _loadShopDetails();
  }

  Future<void> _loadShopDetails() async {
    final token = await _authStorage.readToken();
    if (!mounted || token == null || token.isEmpty) return;

    try {
      final response =
          await _authService.fetchSellerShopDetails(authToken: token);
      if (!mounted) return;
      final details =
          response['details'] is Map ? response['details'] as Map : null;
      if (details == null) return;

      final name = details['name']?.toString() ??
          details['shop_name']?.toString();
      final phone = details['shop_phone']?.toString();
      final slug = details['slug']?.toString();
      final logo = details['logo']?.toString() ??
          details['shop_logo']?.toString();
      final status = details['status'];

      final resolvedLogo = _resolveMediaUrl(logo);

      setState(() {
        if (name != null && name.trim().isNotEmpty) {
          _shopName = name.trim();
        }
        if (phone != null && phone.trim().isNotEmpty) {
          _shopPhone = phone.trim();
        }
        if (slug != null && slug.trim().isNotEmpty) {
          _shopSlug = slug.trim();
        }
        if (resolvedLogo != null && resolvedLogo.isNotEmpty) {
          _shopLogoUrl = resolvedLogo;
        }
        if (status is int) {
          _shopStatus = status;
        } else if (status is String) {
          _shopStatus = int.tryParse(status);
        }
      });
    } catch (e, stackTrace) {
      debugPrint('SellerDrawer load shop details failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String? _resolveMediaUrl(String? path) {
    final resolved = ApiConfig.resolveMediaUrl(path);
    return resolved.isEmpty ? null : resolved;
  }

  void _navigateTo(BuildContext context, String routeName) {
    final navigator = Navigator.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    navigator.pop();
    if (currentRoute != routeName) {
      navigator.pushNamed(routeName);
    }
  }

  void _showPlaceholder(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context);
    Navigator.of(context).pop();
    showAppSnackBar(context, l10n.drawerComingSoon(label));
  }

  void _confirmLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    navigator.pop();
    showDialog(
      context: navigator.context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                        Icons.logout,
                        color: kBrandColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.drawerLogOutTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: kInkColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.drawerLogOutMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
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
                        onPressed: () => Navigator.of(dialogContext).pop(),
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
                          l10n.drawerCancel,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: kBrandColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          navigator.pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          l10n.drawerLogOut,
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final headerTitle =
        _shopName != null && _shopName!.isNotEmpty ? _shopName! : l10n.welcomeAppName;
    final headerSubtitle = _shopPhone != null && _shopPhone!.isNotEmpty
        ? _shopPhone!
        : _shopSlug;
    final isActive = _shopStatus == null || _shopStatus == 1;
    final statusLabel =
        isActive ? l10n.drawerActive : l10n.productsStatusInactive;
    final statusColor = isActive ? kBrandColor : kWarningColor;

    return Drawer(
      backgroundColor: kSurfaceColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              padding: const EdgeInsets.all(16),
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
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _shopLogoUrl != null &&
                                  _shopLogoUrl!.isNotEmpty
                              ? Image.network(
                                  _shopLogoUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/branding/majdoleen_logo.png',
                                    fit: BoxFit.contain,
                                  ),
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
                              headerTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (headerSubtitle != null &&
                                headerSubtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                headerSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          color: kBrandColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _shopSlug ?? l10n.welcomeAppName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: kInkColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _DrawerNavItem(
                    icon: Icons.storefront_outlined,
                    title: l10n.drawerStoreProfileTitle,
                    subtitle: l10n.drawerStoreProfileSubtitle,
                    isActive: currentRoute == AppRoutes.storeProfile,
                    onTap: () => _navigateTo(context, AppRoutes.storeProfile),
                  ),
                  _DrawerNavItem(
                    icon: Icons.settings_outlined,
                    title: l10n.drawerSettingsTitle,
                    subtitle: l10n.drawerSettingsSubtitle,
                    isActive: currentRoute == AppRoutes.settings,
                    onTap: () => _navigateTo(context, AppRoutes.settings),
                  ),
                  _DrawerNavItem(
                    icon: Icons.support_agent_outlined,
                    title: l10n.drawerSupportTitle,
                    subtitle: l10n.drawerSupportSubtitle,
                    onTap: () =>
                        _showPlaceholder(context, l10n.drawerSupportTitle),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.drawerLogOut),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: kBrandColor.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? kBrandColor.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kSoftShadow,
        border: Border.all(
          color: isActive ? kBrandColor.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: kBrandColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: kBrandColor,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withOpacity(0.6),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
