import 'package:flutter/material.dart';

import 'app_routes.dart';

void handleNavTap(BuildContext context, int index) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final routes = <String>[
    AppRoutes.orders,
    AppRoutes.products,
    AppRoutes.home,
    AppRoutes.payouts,
    AppRoutes.statistics,
  ];

  if (index < 0 || index >= routes.length) {
    return;
  }

  final targetRoute = routes[index];
  if (currentRoute != targetRoute) {
    Navigator.of(context).pushReplacementNamed(targetRoute);
  }
}
