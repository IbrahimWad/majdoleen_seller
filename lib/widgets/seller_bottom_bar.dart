// lib/widgets/seller_bottom_bar.dart

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_nav_items.dart';

const double _barHeight = 62.0;
const double _popupClearance = 18.0;
const double _iconSize = 20.0;
const double _selectedIconSize = 22.0;
const double _horizontalMargin = 14.0;

const Duration _navAnimDuration = Duration(milliseconds: 350);

class SellerBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const SellerBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static double bodyBottomPadding(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final extraBottom = (bottomInset - 8).clamp(0.0, 100.0);
    return _barHeight + _popupClearance + extraBottom + 24;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final extraBottom = (bottomInset - 8).clamp(0.0, 100.0);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth =
    (screenWidth - (_horizontalMargin * 2)).clamp(280.0, 900.0);

    final labels = [
      l10n.navOrders,
      l10n.navProducts,
      l10n.navHome,
      l10n.navPayouts,
      l10n.navStats,
    ];
    assert(labels.length == kMainNavItems.length);

    final itemsLen = kMainNavItems.length;
    final safeIndex = itemsLen == 0 ? 0 : selectedIndex.clamp(0, itemsLen - 1);

    final inactiveColor = scheme.onSurface.withOpacity(0.55);
    final navBackground =
        Color.lerp(scheme.surface, Colors.white, 0.6) ?? scheme.surface;

    final baseLabelStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface.withOpacity(0.75),
    ) ??
        const TextStyle(fontSize: 10, fontWeight: FontWeight.w600);

    final selectedLabelStyle = baseLabelStyle.copyWith(color: kBrandColor);

    return SizedBox(
      height: _barHeight + _popupClearance + extraBottom,
      child: Padding(
        padding: EdgeInsets.only(bottom: extraBottom),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalMargin),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _barHeight,
                child: Center(
                  child: SizedBox(
                    width: maxWidth,
                    height: _barHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_barHeight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.16),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 6,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: CurvedNavigationBar(
                        index: safeIndex,
                        height: _barHeight,
                        maxWidth: maxWidth,
                        color: navBackground,
                        backgroundColor: Colors.transparent,
                        buttonBackgroundColor: kBrandColor,
                        animationDuration: _navAnimDuration,
                        animationCurve: Curves.easeOutCubic,
                        items: List.generate(itemsLen, (i) {
                          final item = kMainNavItems[i];
                          final isSelected = i == safeIndex;

                          return CurvedNavigationBarItem(
                            child: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              size:
                              isSelected ? _selectedIconSize : _iconSize,
                              color: isSelected ? Colors.white : inactiveColor,
                            ),
                            label: labels[i],
                            labelStyle: isSelected
                                ? selectedLabelStyle
                                : baseLabelStyle,
                          );
                        }),
                        onTap: onTap,
                      ),
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
