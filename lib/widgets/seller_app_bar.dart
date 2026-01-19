import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../core/app_colors.dart';
import '../services/auth_storage.dart';
import '../services/seller_auth_service.dart';

class SellerAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String shopName;
  final String shopImagePath;

  const SellerAppBar({
    super.key,
    this.shopName = 'Majdoleen Seller',
    this.shopImagePath = 'assets/branding/majdoleen_logo.png',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SellerAppBar> createState() => _SellerAppBarState();
}

class _SellerAppBarState extends State<SellerAppBar> {
  final AuthStorage _authStorage = AuthStorage();
  final SellerAuthService _authService = const SellerAuthService();

  String? _shopName;
  String? _shopLogoUrl;

  @override
  void initState() {
    super.initState();
    _shopName = widget.shopName;
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
      final logo = details['logo']?.toString() ??
          details['shop_logo']?.toString();
      final resolvedLogo = _resolveMediaUrl(logo);

      setState(() {
        if (name != null && name.trim().isNotEmpty) {
          _shopName = name.trim();
        }
        if (resolvedLogo != null && resolvedLogo.isNotEmpty) {
          _shopLogoUrl = resolvedLogo;
        }
      });
    } catch (e, stackTrace) {
      debugPrint('SellerAppBar load shop details failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String? _resolveMediaUrl(String? path) {
    final resolved = ApiConfig.resolveMediaUrl(path);
    return resolved.isEmpty ? null : resolved;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shopName = _shopName ?? widget.shopName;
    final logoUrl = _shopLogoUrl;

    return AppBar(
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'Menu',
        ),
      ),
      leadingWidth: 56,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBrandColor.withOpacity(0.08)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: logoUrl != null && logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset(
                        widget.shopImagePath,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Image.asset(
                      widget.shopImagePath,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              shopName,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
        ),
      ],
    );
  }
}
