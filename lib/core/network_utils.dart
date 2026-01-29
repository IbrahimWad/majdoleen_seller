import 'package:flutter/widgets.dart';

import 'connectivity_controller.dart';

bool isOffline(BuildContext context) {
  final connectivity = ConnectivityScope.of(context);
  return connectivity.initialized && !connectivity.isOnline;
}

bool isNetworkError(Object error) {
  final message = error.toString().toLowerCase();
  return message.contains('network') ||
      message.contains('socketexception') ||
      message.contains('failed to connect') ||
      message.contains('connection error') ||
      message.contains('connection refused') ||
      message.contains('connection reset') ||
      message.contains('timed out') ||
      message.contains('timeout') ||
      message.contains('host lookup') ||
      message.contains('no internet') ||
      message.contains('network is unreachable');
}
