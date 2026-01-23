// lib/widgets/seller_bottom_bar.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_nav_items.dart';

const double _barHeight = 68.0;

// Home button
const double _fabSize = 55.0;
const double _fabRadius = 17.0;

// ✅ تحكم ارتفاع زر/ايقونة الهوم
// قيمة موجبة = ينزل لتحت، قيمة سالبة = يطلع لفوق
const double _homeBtnYOffset = 8.0; // درجتين لتحت

// Bar
const double _cornerRadius = 30.0;

// Notch tuning
const double _fabLift = 0.0; // خليها مثل ما هي عندك
const double _notchMargin = -29; // 0 يعني يلامس
const double _notchWidthExtra = 45.0; // ✅ أوسع ليبين التجويف
const double _notchDepthExtra = 30.0; // ✅ أعمق ليبين الفراغ تحت الهوم

// Layout
const double _horizontalMargin = 16.0;
const double _innerHorizontalPadding = 6.0;

const double _iconSize = 22.0;

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

    final rFab = _fabSize / 2.0;

    // ✅ مساحة فعلية حسب بروز زر الهوم بعد النزول
    final protrusion = (rFab + _fabLift - _homeBtnYOffset).clamp(0.0, 999.0);

    return _barHeight + extraBottom + protrusion + 16;
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
      l10n.navOrders, // 0
      l10n.navProducts, // 1
      l10n.navHome, // 2
      l10n.navPayouts, // 3
      l10n.navStats, // 4
    ];
    assert(labels.length == kMainNavItems.length);
    assert(kMainNavItems.length >= 5);

    final safeSelected = selectedIndex.clamp(0, kMainNavItems.length - 1);

    final isDark = theme.brightness == Brightness.dark;
    final surface = scheme.surface;
    final primary = kBrandColor;
    final inactive = scheme.onSurfaceVariant.withOpacity(isDark ? 0.65 : 0.55);

    final rFab = _fabSize / 2.0;

    // ✅ عمق التجويف = مقدار دخول الزر داخل البار + زيادة (حتى يبان الفراغ تحت الزر)
    // ✅ مراعاة نزول زر الهوم
    final overlapIntoBar = (rFab - _fabLift + _notchMargin + _homeBtnYOffset);
    final notchDepth =
    (overlapIntoBar + _notchDepthExtra).clamp(14.0, _barHeight * 0.92);

    // ✅ عرض التجويف
    final notchWidth =
    (_fabSize + _notchWidthExtra).clamp(_fabSize + 28.0, _fabSize + 110.0);

    const leftA = 0;
    const leftB = 1;
    const rightA = 3;
    const rightB = 4;

    final homeColor = safeSelected == 2 ? primary : surface;
    final homeIconColor = safeSelected == 2 ? Colors.white : inactive;
    final homeLabelColor = safeSelected == 2 ? primary : inactive;

    return SizedBox(
      height: _barHeight + extraBottom,
      child: Padding(
        padding: EdgeInsets.only(bottom: extraBottom),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalMargin),
          child: Stack(
            alignment: Alignment.bottomCenter,
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
                    child: PhysicalShape(
                      clipBehavior: Clip.antiAlias,
                      elevation: 14,
                      shadowColor:
                      Colors.black.withOpacity(isDark ? 0.40 : 0.18),
                      color: surface,
                      clipper: _BottomBarSmoothNotchClipper(
                        cornerRadius: _cornerRadius,
                        notchWidth: notchWidth,
                        notchDepth: notchDepth,
                      ),
                      child: MediaQuery.withClampedTextScaling(
                        minScaleFactor: 1.0,
                        maxScaleFactor: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _innerHorizontalPadding,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _NavBtn(
                                  isActive: safeSelected == leftA,
                                  label: labels[leftA],
                                  icon: kMainNavItems[leftA].icon,
                                  activeIcon: kMainNavItems[leftA].selectedIcon,
                                  activeColor: primary,
                                  inactiveColor: inactive,
                                  onTap: () => onTap(leftA),
                                ),
                              ),
                              Expanded(
                                child: _NavBtn(
                                  isActive: safeSelected == leftB,
                                  label: labels[leftB],
                                  icon: kMainNavItems[leftB].icon,
                                  activeIcon: kMainNavItems[leftB].selectedIcon,
                                  activeColor: primary,
                                  inactiveColor: inactive,
                                  onTap: () => onTap(leftB),
                                ),
                              ),
                              SizedBox(width: notchWidth),
                              Expanded(
                                child: _NavBtn(
                                  isActive: safeSelected == rightA,
                                  label: labels[rightA],
                                  icon: kMainNavItems[rightA].icon,
                                  activeIcon: kMainNavItems[rightA].selectedIcon,
                                  activeColor: primary,
                                  inactiveColor: inactive,
                                  onTap: () => onTap(rightA),
                                ),
                              ),
                              Expanded(
                                child: _NavBtn(
                                  isActive: safeSelected == rightB,
                                  label: labels[rightB],
                                  icon: kMainNavItems[rightB].icon,
                                  activeIcon: kMainNavItems[rightB].selectedIcon,
                                  activeColor: primary,
                                  inactiveColor: inactive,
                                  onTap: () => onTap(rightB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ "الرئيسية" تحت زر الهوم (ضمن عرض التجويف حتى ما تختفي)
              Positioned(
                bottom: 6,
                child: IgnorePointer(
                  child: SizedBox(
                    width: notchWidth,
                    child: Center(
                      child: Text(
                        labels[2],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: homeLabelColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Home button
              Positioned(
                // ✅ تتحكم من _homeBtnYOffset بارتفاع زر الهوم
                top: -(_fabLift + rFab) + _homeBtnYOffset,
                child: SizedBox(
                  width: _fabSize,
                  height: _fabSize,
                  child: Material(
                    elevation: 10,
                    color: homeColor,
                    borderRadius: BorderRadius.circular(_fabRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(_fabRadius),
                      onTap: () => onTap(2),
                      child: Center(
                        child: Icon(
                          kMainNavItems[2].selectedIcon,
                          size: 26,
                          color: homeIconColor,
                        ),
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

class _NavBtn extends StatelessWidget {
  final bool isActive;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBtn({
    required this.isActive,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = isActive ? activeColor : inactiveColor;

    return InkResponse(
      onTap: onTap,
      radius: 30,
      child: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isActive ? activeIcon : icon, size: _iconSize, color: c),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: c,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ تجويف موجة انسيابية + ✅ قص Hole شفاف (يظهر اللي خلف البار)
class _BottomBarSmoothNotchClipper extends CustomClipper<Path> {
  _BottomBarSmoothNotchClipper({
    required this.cornerRadius,
    required this.notchWidth,
    required this.notchDepth,
  });

  final double cornerRadius;
  final double notchWidth;
  final double notchDepth;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = cornerRadius;

    final cx = w / 2.0;

    final rawX0 = cx - notchWidth / 2.0;
    final rawX1 = cx + notchWidth / 2.0;

    // حماية من دخول التجويف في الكورنر
    final safeX0 = math.max(rawX0, r + 8.0);
    final safeX1 = math.min(rawX1, w - r - 8.0);

    final effectiveNotchWidth = safeX1 - safeX0;

    // ✅ قاع أعرض بدل ما يكون نقطة
    final flatBottomWidth = (effectiveNotchWidth * 0.34).clamp(22.0, 52.0);
    final flatL = cx - flatBottomWidth / 2.0;
    final flatR = cx + flatBottomWidth / 2.0;

    // تحكم بالنعومة
    final shoulder = effectiveNotchWidth * 0.22;

    // 1) الشكل الخارجي للبار بدون تجويف
    final outer = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h),
          Radius.circular(r),
        ),
      );

    // 2) شكل التجويف كمنطقة مغلقة ليتم قصها (Hole) وتصبح شفافة
    final cutout = Path()
      ..moveTo(safeX0, 0)
      ..cubicTo(
        safeX0 + shoulder,
        0,
        flatL - shoulder,
        notchDepth,
        flatL,
        notchDepth,
      )
      ..lineTo(flatR, notchDepth)
      ..cubicTo(
        flatR + shoulder,
        notchDepth,
        safeX1 - shoulder,
        0,
        safeX1,
        0,
      )
      ..close();

    // ✅ قص التجويف من البار ليصبح شفاف ويظهر ما خلفه
    return Path.combine(PathOperation.difference, outer, cutout);
  }

  @override
  bool shouldReclip(covariant _BottomBarSmoothNotchClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchWidth != notchWidth ||
        oldClipper.notchDepth != notchDepth;
  }
}
