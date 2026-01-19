import 'package:flutter/material.dart';

class NavItemData {
  final IconData icon;
  final IconData selectedIcon;

  const NavItemData({
    required this.icon,
    required this.selectedIcon,
  });
}

const List<NavItemData> kMainNavItems = [
  NavItemData(
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
  ),
  NavItemData(
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
  ),
  NavItemData(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  NavItemData(
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
  ),
  NavItemData(
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
  ),
];
