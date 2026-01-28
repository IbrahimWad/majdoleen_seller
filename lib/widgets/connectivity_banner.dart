import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/connectivity_controller.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ConnectivityScope.of(context);
    final isOffline = controller.initialized && !controller.isOnline;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final message =
        isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
    final detail = isArabic ? 'غير متصل' : 'Offline';

    return AnimatedSlide(
      offset: isOffline ? Offset.zero : const Offset(0, -1.2),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isOffline ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: SafeArea(
          bottom: false,
          child: Material(
            color: kDangerColor,
            elevation: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Text(
                    detail,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
