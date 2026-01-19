import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_shadows.dart';
import 'welcome_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final Locale deviceLocale;
  final Future<void> Function(Locale) onSelected;

  const LanguageSelectionScreen({
    super.key,
    required this.deviceLocale,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabicDevice = deviceLocale.languageCode == 'ar';
    final detectedLabel = isArabicDevice ? 'العربية' : 'English';
    final detectedLocale =
        isArabicDevice ? const Locale('ar') : const Locale('en');
    final useLabel = isArabicDevice ? 'استخدام' : 'Use';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kSurfaceColor, Color(0xFFFDFBFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: kSoftShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/branding/majdoleen_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Majdoleen Seller',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Choose your language',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر اللغة المفضلة لك',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: kInkColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                    border: Border.all(color: kBrandColor.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kBrandColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: kBrandColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detected on your device',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: kInkColor.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detectedLabel,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await onSelected(detectedLocale);
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const WelcomeScreen(),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(useLabel),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Or select manually',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أو اختر يدوياً',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _LanguageOptionCard(
                        title: 'العربية',
                        subtitle: 'Arabic',
                        isRecommended: isArabicDevice,
                        onTap: () async {
                          await onSelected(const Locale('ar'));
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const WelcomeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LanguageOptionCard(
                        title: 'English',
                        subtitle: 'English',
                        isRecommended: !isArabicDevice,
                        onTap: () async {
                          await onSelected(const Locale('en'));
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const WelcomeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Your choice will be saved on this device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سيتم حفظ اختيارك على هذا الجهاز.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kInkColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isRecommended;
  final VoidCallback onTap;

  const _LanguageOptionCard({
    required this.title,
    required this.subtitle,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  isRecommended ? kBrandColor : kBrandColor.withOpacity(0.12),
            ),
            boxShadow: kSoftShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRecommended)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kBrandColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Recommended',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: kBrandColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kInkColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
