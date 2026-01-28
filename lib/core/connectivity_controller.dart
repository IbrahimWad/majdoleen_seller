import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityController extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult> _results = const [ConnectivityResult.none];
  bool _initialized = false;

  bool get initialized => _initialized;
  bool get isOnline => !_results.contains(ConnectivityResult.none);
  List<ConnectivityResult> get results => List.unmodifiable(_results);

  Future<void> initialize() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateResults(results);
      _subscription =
          _connectivity.onConnectivityChanged.listen(_updateResults);
    } catch (_) {
      _initialized = true;
      notifyListeners();
    }
  }

  void _updateResults(List<ConnectivityResult> results) {
    _results = results.isEmpty ? const [ConnectivityResult.none] : results;
    _initialized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class ConnectivityScope extends InheritedNotifier<ConnectivityController> {
  const ConnectivityScope({
    super.key,
    required ConnectivityController controller,
    required super.child,
  }) : super(notifier: controller);

  static ConnectivityController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ConnectivityScope>();
    assert(scope != null, 'ConnectivityScope not found in widget tree.');
    return scope!.notifier!;
  }
}
