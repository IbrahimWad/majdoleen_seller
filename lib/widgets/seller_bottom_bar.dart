import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_nav_items.dart';

const double _barHeight = 56;
const double _sideIconSize = 18;
const double _sideSelectedSize = 30;
const double _centerButtonSize = 46;
const double _centerIconSize = 22;
const double _centerBumpSize = 62;
const double _horizontalMargin = 14;
const double _dotSize = 4;

const Duration _navAnimDuration = Duration(milliseconds: 250);

class SellerBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const SellerBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final labels = [
      l10n.navOrders,
      l10n.navProducts,
      l10n.navHome,
      l10n.navPayouts,
      l10n.navStats,
    ];
    assert(labels.length == kMainNavItems.length);

    final centerIndex = kMainNavItems.length ~/ 2;
    final centerSlotWidth = _centerBumpSize + 6;
    final navBackground =
        Color.lerp(scheme.surface, Colors.white, 0.6) ?? scheme.surface;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: (bottomInset - 8).clamp(0.0, 100.0)),
        child: SizedBox(
          height: _barHeight + (_centerBumpSize / 2),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: _horizontalMargin,
                right: _horizontalMargin,
                bottom: 0,
                child: Container(
                  height: _barHeight,
                  decoration: BoxDecoration(
                    color: navBackground,
                    borderRadius: BorderRadius.circular(_barHeight),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 1.0,
                    ),
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
                  child: Row(
                    children: [
                      for (var index = 0; index < centerIndex; index++)
                        Expanded(
                          child: _SideNavItem(
                            item: kMainNavItems[index],
                            label: labels[index],
                            isSelected: index == selectedIndex,
                            onTap: () => onTap(index),
                          ),
                        ),
                      SizedBox(
                        width: centerSlotWidth,
                        child: _CenterNavLabel(
                          label: labels[centerIndex],
                          isSelected: selectedIndex == centerIndex,
                        ),
                      ),
                      for (var index = centerIndex + 1;
                          index < kMainNavItems.length;
                          index++)
                        Expanded(
                          child: _SideNavItem(
                            item: kMainNavItems[index],
                            label: labels[index],
                            isSelected: index == selectedIndex,
                            onTap: () => onTap(index),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: _barHeight - (_centerBumpSize / 2),
                child: Container(
                  width: _centerBumpSize,
                  height: _centerBumpSize,
                  decoration: BoxDecoration(
                    color: navBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.95),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.9),
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: _barHeight - (_centerButtonSize / 2),
                child: _CenterNavButton(
                  item: kMainNavItems[centerIndex],
                  label: labels[centerIndex],
                  isSelected: selectedIndex == centerIndex,
                  onTap: () => onTap(centerIndex),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final NavItemData item;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.item,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inactiveColor = scheme.onSurface.withOpacity(0.55);
    final accentColor = scheme.primary;
    final iconColor = isSelected ? accentColor : inactiveColor;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: iconColor,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 10,
        );

    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: _barHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: _navAnimDuration,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: isSelected
                      ? _AccentCircleIcon(
                          key: const ValueKey('selected'),
                          icon: item.selectedIcon,
                          size: _sideSelectedSize,
                          iconSize: _sideIconSize,
                        )
                      : Icon(
                          item.icon,
                          key: const ValueKey('unselected'),
                          color: iconColor,
                          size: _sideIconSize,
                        ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: _navAnimDuration,
                  style: textStyle ?? const TextStyle(),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedOpacity(
                  duration: _navAnimDuration,
                  opacity: isSelected ? 1 : 0,
                  child: const _IndicatorDot(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterNavButton extends StatelessWidget {
  final NavItemData item;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterNavButton({
    required this.item,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkResponse(
          onTap: onTap,
          radius: _centerButtonSize / 2,
          child: _AccentCircleIcon(
            icon: isSelected ? item.selectedIcon : item.icon,
            size: _centerButtonSize,
            iconSize: _centerIconSize,
          ),
        ),
      ),
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _CenterNavLabel extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _CenterNavLabel({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inactiveColor = scheme.onSurface.withOpacity(0.55);
    final accentColor = scheme.primary;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isSelected ? accentColor : inactiveColor,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 10,
        );

    return SizedBox(
      height: _barHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: _sideSelectedSize),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: _navAnimDuration,
            style: textStyle ?? const TextStyle(),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedOpacity(
            duration: _navAnimDuration,
            opacity: isSelected ? 1 : 0,
            child: const _IndicatorDot(),
          ),
        ],
      ),
    );
  }
}

class _AccentCircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const _AccentCircleIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final accentLight = Color.lerp(accent, Colors.white, 0.35) ?? accent;
    final accentDark = Color.lerp(accent, Colors.black, 0.25) ?? accent;
    final borderWidth = (size * 0.03).clamp(0.8, 1.4).toDouble();
    final shadowBlur = size * 0.35;
    final shadowOffset = size * 0.18;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentLight, accent, accentDark],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.55),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: shadowBlur,
            offset: Offset(0, shadowOffset),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
