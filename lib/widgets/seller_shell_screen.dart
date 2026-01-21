import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/payouts_screen.dart';
import '../screens/products_screen.dart';
import '../screens/statistics_screen.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';

class SellerShellScope extends InheritedWidget {
  final int index;
  final ValueChanged<int> setIndex;

  const SellerShellScope({
    super.key,
    required this.index,
    required this.setIndex,
    required super.child,
  });

  static SellerShellScope of(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<SellerShellScope>();
    assert(scope != null, 'SellerShellScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant SellerShellScope oldWidget) {
    return oldWidget.index != index;
  }
}

class SellerShellScreen extends StatefulWidget {
  const SellerShellScreen({super.key});

  @override
  State<SellerShellScreen> createState() => _SellerShellScreenState();
}

class _SellerShellScreenState extends State<SellerShellScreen> {
  int _selectedIndex = 2;

  late final List<Widget> _pages = const [
    OrdersScreen(),
    ProductsScreen(),
    HomeScreen(),
    PayoutsScreen(),
    StatisticsScreen(),
  ];

  void _setIndex(int i) {
    if (i == _selectedIndex) return;
    setState(() => _selectedIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return SellerShellScope(
      index: _selectedIndex,
      setIndex: _setIndex,
      child: Scaffold(
        extendBody: true,
        appBar: const SellerAppBar(),
        drawer: const SellerDrawer(),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: SellerBottomBar(
          selectedIndex: _selectedIndex,
          onTap: _setIndex,
        ),
      ),
    );
  }
}
